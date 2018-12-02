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
    func setTop(visible: Bool)
}

class ImportWalletVC: PopupVC {
    
    private let mArrow   = UIImageView(image: UIImage(named: "arrowDown"))
    private let mPicker  = CryptoList()
    private let mBlock   = UILabel.new(font: UIFont.proMedium(25.scaled), text: "select_chain".loc, lines: 1, color: Style.Colors.black, alignment: .center)
    
    private let mCancel = Button().apply({
        $0.setTitle("cancel".loc, for: .normal)
        $0.backgroundColor = Style.Colors.darkGrey
    })
    
    private let mImport = Button().apply({
        $0.setTitle("import".loc, for: .normal)
        $0.backgroundColor = Style.Colors.blue
        $0.isActive = false
    })
    
    private var mBlockchain: Blockchain?
    
    private let mETHForm = ETHForm()
    private let mEOSForm = EOSForm()
    
    private weak var mDelegate: ImportDelegate?
    
    init(delegate: ImportDelegate?) {
        mDelegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        content.addSubview(mPicker)
        content.addSubview(mArrow)
        content.addSubview(mBlock)
        content.addSubview(mETHForm)
        content.addSubview(mEOSForm)
        content.addSubview(mCancel)
        content.addSubview(mImport)
        mPicker.onSelect = { [weak self] b in
            self?.selected(blockchain: b)
        }
        mCancel.click = { [weak self] in
            self?.dismiss(animated: true)
        }
        mImport.click = { [weak self] in
            self?.doImport()
        }
        mETHForm.onValid = { [weak self] v in
            self?.mImport.isActive = v
        }
        mETHForm.onDerive = { [weak self] in
            self?.derive()
        }
        mETHForm.onScan = { [weak self] in
            self?.startScanner()
        }
        mEOSForm.onSearch = { [weak self] s -> Bool in
            return self?.searchEOS(s) ?? true
        }
        mEOSForm.onValid = { [weak self] v in
            self?.mImport.isActive = v
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIApplication.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIApplication.keyboardWillHideNotification, object: nil)
    }
    
    override func doLayout() -> CGFloat {
        mArrow.origin = CGPoint(x: (view.width - mArrow.width)/2.0, y: 40.scaled)
        mBlock.alpha  = mBlockchain == nil ? 1.0 : 0.0
        mBlock.origin = CGPoint(x: (view.width - mBlock.width)/2.0, y: mArrow.maxY + 40.scaled)
        mPicker.frame = CGRect(x: 0, y:  mBlockchain == nil ? mBlock.maxY : mArrow.maxY, width: view.width, height: 0)
        mPicker.setNeedsLayout()
        mPicker.layoutIfNeeded()

        mETHForm.frame = CGRect(x: 0, y: mPicker.maxY, width: view.width, height: 0)
        mETHForm.setNeedsLayout()
        mETHForm.layoutIfNeeded()
        
        mEOSForm.frame = CGRect(x: 0, y: mPicker.maxY, width: view.width, height: 0)
        mEOSForm.setNeedsLayout()
        mEOSForm.layoutIfNeeded()
        
        mETHForm.alpha = mBlockchain == .ETH ? 1.0 : 0.0
        mEOSForm.alpha = mBlockchain == .EOS ? 1.0 : 0.0
        mBlock.textColor = mBlockchain != nil ? Style.Colors.blue : Style.Colors.black
        mImport.isActive = mBlockchain == .ETH ? mETHForm.isValid : mEOSForm.isValid
        
        let y = doit {
            switch mBlockchain {
            case .none: return mPicker.maxY
            case .some(.ETH): return mETHForm.maxY
            case .some(.EOS): return mEOSForm.maxY
            }
        } + 30.scaled
        
        let p = 40.scaled
        let w = (view.width - p * 3.0)/2.0
        
        mCancel.frame = CGRect(x: p, y: y, width: w, height: Style.Dims.buttonMiddle)
        mImport.frame = CGRect(x: mCancel.maxX + p, y: mCancel.minY, width: w, height: mCancel.height)
        return mCancel.maxY + p
    }
    
    private func selected(blockchain: Blockchain) {
        mBlockchain = blockchain
        view.endEditing(true)
        UIView.animate(withDuration: 0.25, animations: {
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
        })
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
    
    private func doImport() {
        guard let b = mBlockchain else { return }
        switch b {
        case .ETH:
            let name = mETHForm.value
            if name.count > 0, (name.split(separator: " ").count == 12 || name.split(separator: " ").count == 24) {
                onNew(chain: b, name: "", seed: name)
            } else if name.count > 0, name.range(of: " ") == nil {
                onNew(chain: b, name: "", privateKey: name)
            } else {
                mETHForm.shakeField()
            }
        case .EOS:
            if
                let p = mEOSForm.privateKey,
                let a = mEOSForm.selected,
                let w = EOSWallet(name: a, data: "00\(p)", privateKey: p, time: Date().timeIntervalSince1970) {
                AppDelegate.lock()
                dismiss(animated: true, completion: {
                    self.mDelegate?.onNew(wallet: w)
                    AppDelegate.unlock()
                })
            } else {
                mEOSForm.shakeField()
            }
        }
    }
    
    private func onNew(chain: Blockchain, name: String, seed: String) {
        guard let s = try? Mnemonic.createSeed(mnemonic: seed.split(separator: " ").map({ String($0) })) else {
            mETHForm.shakeField()
            return
        }
        AppDelegate.lock()
        dismiss(animated: true, completion: {
            self.mDelegate?.onNew(chain: chain, name: name, data: "01\(s.toHexString())", segwit: false)
            AppDelegate.unlock()
        })
    }
    
    private func onNew(chain: Blockchain, name: String, privateKey: String) {
        AppDelegate.lock()
        dismiss(animated: true, completion: {
            self.mDelegate?.onNew(chain: chain, name: name, data: "00\(privateKey.withoutPrefix)", segwit: false)
            AppDelegate.unlock()
        })
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
            self?.mETHForm.value = json
            vc?.dismiss(animated: true, completion: nil)
        }
        present(vc, animated: true, completion: nil)
    }
    
    private func searchEOS(_ pk: String) -> Bool {
        do {
            let parts = pk.split(separator: " ")
            let pk = parts.count == 1 ? try PrivateKey(keyString: pk) : try PrivateKey(mnemonicString: pk, index: 0)
            guard let pk2 = pk else {
                throw "PK is null"
            }
            let hud = HUD.show()
            EOSRPC.sharedInstance.getKeyAccounts(pub: PublicKey(privateKey: pk2).rawPublicKey(), completion: { [weak self] r, e in
                hud?.hide(animated: true)
                self?.mEOSForm.update(pk: pk2.rawPrivateKey(),
                                      accounts: r?.accountNames ?? [],
                                      completion: { [weak self] in
                                        self?.view.setNeedsLayout()
                                        self?.view.layoutIfNeeded() })
            })
            return true
        } catch let e {
            print("\(e)")
            mEOSForm.shakeField()
            return false
        }
    }
    
}
