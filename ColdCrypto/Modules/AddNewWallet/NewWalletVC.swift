//
//  ImportWalletVC.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 02/12/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import UIKit

protocol ImportDelegate: class {
    func onNew(chain: Blockchain, name: String, data: String, segwit: Bool, network: INetwork, backup: Bool)
    func onNew(wallet: IWallet)
}

class NewWalletVC: AlertVC, AddWalletDelegate {

    private var mBlockchain: Blockchain?
    private var mNetwork: INetwork?
    private var mActive: (UIView & IWithValue)?
    
    private let mView = NewWalletView()
    
    private let mPicker = NetworkPicker()
    
    private weak var mDelegate: ImportDelegate?
    
    private var mScanner: ScannerView?

    init(delegate: ImportDelegate?) {
        mDelegate = delegate
        super.init(nil, view: mView, style: .sheet, arrow: true, withButtons: false)
        mView.delegate = self
        mPicker.onSelected = { [weak self] network in
            self?.onSelected(network: network)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIApplication.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIApplication.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(_ n: Any?) {
        (n as? Notification)?.keyboard { (rect, time, curve) in
            guard let field = UIResponder.currentFirst() as? UIView else { return }
            guard let w = self.view.window else { return }
            let f = w.convert(field.bounds, from: field)
            if f.maxY > rect.minY {
                UIView.animate(withDuration: time, delay: 0.0, options: UIView.AnimationOptions(rawValue: curve << 16), animations: {
                    self.content.transform = CGAffineTransform(translationX: 0, y: rect.minY-f.maxY - 10.scaled)
                }, completion: nil)
            }
        }
    }
    
    @objc private func keyboardWillHide(_ n: Any?) {
        (n as? Notification)?.keyboard { (rect, time, curve) in
            UIView.animate(withDuration: time, delay: 0.0, options: UIView.AnimationOptions(rawValue: curve << 16), animations: {
                self.content.transform = .identity
            }, completion: nil)
        }
    }
    
    private func onNew(chain: Blockchain, name: String, seed: String, network: INetwork, backup: Bool) {
        guard let s = try? Mnemonic.createSeed(mnemonic: seed.split(separator: " ").map({ String($0) })) else {
            mActive?.shakeField()
            return
        }
        AppDelegate.lock()
        dismiss(animated: true, completion: {
            let d = "01\(s.toHexString())"
            self.mDelegate?.onNew(chain: chain, name: name, data: d, segwit: false,
                                  network: network, backup: backup)
            AppDelegate.unlock()
        })
    }
    
    private func onNew(chain: Blockchain, name: String, privateKey: String, network: INetwork) {
        AppDelegate.lock()
        dismiss(animated: true, completion: {
            let d = "00\(privateKey.withoutPrefix)"
            self.mDelegate?.onNew(chain: chain, name: name, data: d, segwit: false,
                                  network: network, backup: false)
            AppDelegate.unlock()
        })
    }
    
    private func derive() {
        guard let b = mBlockchain, let n = mNetwork else { return }
        onNew(chain: b, name: "", seed: Mnemonic.create().joined(separator: " "), network: n, backup: true)
    }
    
    private func startScanner() {
        let newView = ScannerView()
        newView.withHint = false
        newView.onFound  = { [weak self] json in
            self?.mActive?.value = json.trimmingCharacters(in: .whitespacesAndNewlines)
            self?.popToRoot()
        }
        
        mScanner?.stop()
        mScanner = newView
        update(view: newView, configure: { [weak self] in
            self?.put("delete_no".loc, hide: false, do: { [weak self] _ in
                self?.popToRoot()
            })
            newView.start()
        })
    }
    
    private func popToRoot() {
        mScanner?.stop()
        mScanner = nil
        update(view: mView, configure: { [weak self] in
            self?.withButtons = false
            self?.clearButtons()
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        mScanner?.start()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mScanner?.stop()
    }
    
    private func searchEOS(_ pk: String, view form: EOSForm) -> Bool {
        guard let n = mNetwork else { return false }
        
        let hud = HUD.show()
        EOSWallet.getAccounts(pub: pk, network: n, completion: { accounts, privateKey in
            hud?.hide(animated: true)
            
            if let accs = accounts, let pk = privateKey {
                form.update(pk: pk, accounts: accs, completion: { [weak self] in
                    self?.view.setNeedsLayout()
                    self?.view.layoutIfNeeded()
                })
            } else {
                form.shakeField()
            }
        })
        return true
    }
    
    private func onSelected(network: INetwork) {
        guard let b = mBlockchain else { return }
        mNetwork = network
        
        switch b {
        case .ETH:
            let form = ETHForm()
            form.onDerive = { [weak self] in
                self?.derive()
            }
            form.onScan = { [weak self] in
                self?.startScanner()
            }
            form.onImport = { [weak self, weak form] in
                let name = form?.value ?? ""
                if name.count > 0, (name.split(separator: " ").count == 12 || name.split(separator: " ").count == 24) {
                    self?.onNew(chain: b, name: "", seed: name, network: network, backup: false)
                } else if name.count > 0, name.range(of: " ") == nil {
                    self?.onNew(chain: b, name: "", privateKey: name, network: network)
                } else {
                    form?.shakeField()
                }
            }
            mActive = form
        case .EOS:
            let form = EOSForm()
            form.onScan = { [weak self] in
                self?.startScanner()
            }
            form.onSearch = { [weak self, weak form] s -> Bool in
                guard let f = form else { return true }
                return self?.searchEOS(s, view: f) ?? true
            }
            form.onImport = { [weak self, weak form] in
                if
                    let p = form?.privateKey,
                    let a = form?.selected,
                    let w = EOSWallet(network: network, name: a, data: "00\(p)", privateKey: p) {
                    AppDelegate.lock()
                    self?.dismiss(animated: true, completion: { [weak self] in
                        self?.mDelegate?.onNew(wallet: w)
                        AppDelegate.unlock()
                    })
                } else {
                    form?.shakeField()
                }
            }
            mActive = form
        }
        if let v = mActive {
            v.alpha = 0.0
            mView.append(view: v)
            UIView.animate(withDuration: 0.25, animations: {
                v.alpha = 1.0
                self.view.setNeedsLayout()
                self.view.layoutIfNeeded()
            })
        }
    }
    
    // MAARK:- AddWalletDelegate methods
    // -------------------------------------------------------------------------
    func onSelected(blockchain: Blockchain) {
        mPicker.networks = blockchain.networks
        
        mPicker.alpha = 0.0
        mBlockchain = blockchain
        mView.append(view: mPicker)
        UIView.animate(withDuration: 0.25, animations: {
            self.mView.collapseBlockchain()
            self.mPicker.alpha = 1.0
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
        })
    }
    
    func onCancel(sender: NewWalletView) {
        dismiss(animated: true, completion: nil)
    }

}
