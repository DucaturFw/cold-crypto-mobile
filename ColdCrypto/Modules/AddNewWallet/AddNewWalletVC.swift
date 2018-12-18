//
//  ImportWalletVC.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 02/12/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import UIKit
import EthereumKit

protocol ImportDelegate: class {
    func onNew(chain: Blockchain, name: String, data: String, segwit: Bool)
    func onNewHDWallet(chain: Blockchain)
    func onNew(wallet: IWallet)
}

class AddNewWalletVC: AlertVC, AddWalletDelegate {

    private var mBlockchain: Blockchain?
    private var mNetwork: INetwork?
    private var mActive: (UIView & IWithValue)?
    
    private let mView: AddNewWalletView
    
    private let mPicker = NetworkPicker()
    
    private weak var mDelegate: ImportDelegate?

    init(delegate: ImportDelegate?) {
        mDelegate = delegate
        mView = AddNewWalletView()
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
    
//    override func doLayout() -> CGFloat {
//        mArrow.origin = CGPoint(x: (width - mArrow.width)/2.0, y: 40.scaled)
//        mBlock.alpha  = mBlockchain == nil ? 1.0 : 0.0
//        mBlock.origin = CGPoint(x: (width - mBlock.width)/2.0, y: mArrow.maxY + 40.scaled)
//        mPicker.frame = CGRect(x: 0, y:  mBlockchain == nil ? mBlock.maxY : mArrow.maxY, width: width, height: 0)
//        mPicker.setNeedsLayout()
//        mPicker.layoutIfNeeded()

//        mETHForm.frame = CGRect(x: 0, y: mPicker.maxY, width: width, height: 0)
//        mETHForm.setNeedsLayout()
//        mETHForm.layoutIfNeeded()
//
//        mEOSForm.frame = CGRect(x: 0, y: mPicker.maxY, width: width, height: 0)
//        mEOSForm.setNeedsLayout()
//        mEOSForm.layoutIfNeeded()
//
//        mETHForm.alpha = mBlockchain == .ETH ? 1.0 : 0.0
//        mEOSForm.alpha = mBlockchain == .EOS ? 1.0 : 0.0
//        mBlock.textColor = mBlockchain != nil ? Style.Colors.blue : Style.Colors.black
//        mImport.isActive = mBlockchain == .ETH ? mETHForm.isValid : mEOSForm.isValid
        
//        let y = doit {
//            switch mBlockchain {
//            case .none: return mPicker.maxY
//            case .some(.ETH): return mETHForm.maxY
//            case .some(.EOS): return mEOSForm.maxY
//            }
//        } + 30.scaled
//        let y = mPicker.maxY + 30.scaled
//
//        let p = 40.scaled
//        let w = (width - p * 3.0)/2.0
//
//        mCancel.frame = CGRect(x: p, y: y, width: w, height: Style.Dims.middle)
//        mImport.frame = CGRect(x: mCancel.maxX + p, y: mCancel.minY, width: w, height: mCancel.height)
//        return mCancel.maxY + p
//    }
    
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
    
    private func onNew(chain: Blockchain, name: String, seed: String) {
//        guard let s = try? Mnemonic.createSeed(mnemonic: seed.split(separator: " ").map({ String($0) })) else {
//            mETHForm.shakeField()
//            return
//        }
//        AppDelegate.lock()
//        dismiss(animated: true, completion: {
//            self.mDelegate?.onNew(chain: chain, name: name, data: "01\(s.toHexString())", segwit: false)
//            AppDelegate.unlock()
//        })
    }
    
    private func onNew(chain: Blockchain, name: String, privateKey: String) {
//        AppDelegate.lock()
//        dismiss(animated: true, completion: {
//            self.mDelegate?.onNew(chain: chain, name: name, data: "00\(privateKey.withoutPrefix)", segwit: false)
//            AppDelegate.unlock()
//        })
    }
    
    private func derive() {
        guard let b = mBlockchain else { return }
        dismiss(animated: true) {
            self.mDelegate?.onNewHDWallet(chain: b)
        }
    }
    
    private func startScanner() {
        let vc = ScannerVC()
        vc.onFound = { [weak self, weak vc] json in
            self?.mActive?.value = json.trimmingCharacters(in: .whitespacesAndNewlines)
            vc?.dismiss(animated: true, completion: nil)
        }
        present(vc, animated: true, completion: nil)
    }
    
    private func searchEOS(_ pk: String) -> Bool {
//        do {
//            let parts = pk.split(separator: " ")
//            let pk = parts.count == 1 ? try PrivateKey(keyString: pk) : try PrivateKey(mnemonicString: pk, index: 0)
//            guard let pk2 = pk else { throw "PK is null" }
//            let hud = HUD.show()
//            EOSRPC.sharedInstance.getKeyAccounts(pub: PublicKey(privateKey: pk2).rawPublicKey(), completion: { [weak self] r, e in
//                hud?.hide(animated: true)
//                self?.mEOSForm.update(pk: pk2.rawPrivateKey(),
//                                      accounts: r?.accountNames ?? [],
//                                      completion: { [weak self] in
//                                        self?.view.setNeedsLayout()
//                                        self?.view.layoutIfNeeded() })
//            })
//            return true
//        } catch let e {
//            print("\(e)")
//            mEOSForm.shakeField()
//            return false
//        }
        return false
    }
    
    private func onSelected(network: INetwork) {
        guard let b = mBlockchain else { return }
        mNetwork = network
        
        switch b {
        case .ETH:
            let mETHForm = ETHForm()
            mETHForm.alpha = 0.0
            mETHForm.onValid = { [weak self] v in
                self?.mView.isActive = v
            }
            mETHForm.onDerive = { [weak self] in
                self?.derive()
            }
            mETHForm.onScan = { [weak self] in
                self?.startScanner()
            }
            mActive = mETHForm
        case .EOS:
            let mEOSForm = EOSForm()
            mEOSForm.onScan = { [weak self] in
                self?.startScanner()
            }
            mEOSForm.onSearch = { [weak self] s -> Bool in
                return self?.searchEOS(s) ?? true
            }
            mEOSForm.onValid = { [weak self] v in
                self?.mView.isActive = v
            }
            mActive = mEOSForm
        }
        if let v = mActive {
            mView.append(view: v)
        }
        UIView.animate(withDuration: 0.25, animations: {
            self.mActive?.alpha = 1.0
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
        })
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
    
    func onCancel(sender: AddNewWalletView) {
        dismiss(animated: true, completion: nil)
    }
    
}
