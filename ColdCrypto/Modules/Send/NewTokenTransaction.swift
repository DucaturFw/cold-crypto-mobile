//
//  NewTokenTransaction.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 25/02/2019.
//  Copyright © 2019 Kirill Kozhuhar. All rights reserved.
//

import UIKit

class NewTokenTransaction: UIView, IAlertView, UITextFieldDelegate {
    
    private let mName   = UILabel.new(font: UIFont.medium(25.scaled), text: "new_trans".loc, lines: 1, color: Style.Colors.black, alignment: .center)
    private let mSendTo = UILabel.new(font: UIFont.medium(15.scaled), text: "send_to".loc, lines: 1, color: Style.Colors.darkGrey, alignment: .center)
    private let mAmount = UILabel.new(font: UIFont.medium(15.scaled), text: "amount".loc, lines: 1, color: Style.Colors.darkGrey, alignment: .center)

    private let mPicker = TokenPicker(range: ETHToken.tokens)
    
    private let mUnits = Field().apply({
        $0.returnKeyType = .done
        $0.font = UIFont.medium(13.scaled)
        $0.textColor = Style.Colors.darkGrey
        $0.leftView = UIView()
        $0.isCutEnabled = false
        $0.isCopyEnabled = false
        $0.isPasteEnabled = false
        $0.isDeleteEnabled = false
        $0.isSelectEnabled = false
        $0.isSelectAllEnabled = false
        $0.layer.masksToBounds = true
        $0.tintColor = .clear
        $0.textAlignment = .center
        $0.backgroundColor = Style.Colors.light
        $0.layer.cornerRadius = Style.Dims.middle/2.0
    })
    
    private let mScan = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: Style.Dims.middle, height: Style.Dims.middle))).apply({
        $0.layer.cornerRadius = Style.Dims.middle/2.0
        $0.isUserInteractionEnabled = true
        $0.backgroundColor = Style.Colors.darkGrey
        $0.layer.masksToBounds = true
        $0.image = UIImage(named: "scanWhite")
        $0.contentMode = .center
    })
    
    private lazy var mField = Field().apply({ [weak self] in
        $0.delegate = self
        $0.placeholder = "send_destination".loc
    })
    
    private lazy var mAmountField = Field().apply({ [weak self] in
        $0.delegate = self
        $0.placeholder = "0"
    })
    
    private let mCancel = Button().apply({
        $0.setTitleColor(Style.Colors.white, for: .normal)
        $0.backgroundColor = Style.Colors.darkGrey
        $0.setTitle("cancel".loc, for: .normal)
    })
    
    private let mSend = Button().apply({
        $0.setTitleColor(Style.Colors.white, for: .normal)
        $0.backgroundColor = Style.Colors.blue
        $0.setTitle("send".loc, for: .normal)
        $0.isActive = false
    })
    
    private weak var mParent: AlertVC?
    var parent: AlertVC? {
        get {
            return mParent
        }
        set {
            mParent = newValue
        }
    }
    
    private let mWallet: IWallet
    
    private var mKeyboardRect: CGRect?
    
    private var mToken: ETHToken?
    
    private let mSelected: TokenObj?
    
    init(token: TokenObj? = nil, parent: AlertVC?, wallet: IWallet, to: String? = nil) {
        mSelected = token
        mParent = parent
        mWallet = wallet
        super.init(frame: .zero)

        addSubview(mName)
        addSubview(mSendTo)
        addSubview(mScan)
        addSubview(mField)
        addSubview(mAmount)
        addSubview(mAmountField)
        addSubview(mCancel)
        addSubview(mSend)
        addSubview(mUnits)
        
        mUnits.text = mWallet.blockchain.symbol()
        
        mAmountField.returnKeyType = .done
        mField.returnKeyType = .next
        mField.useTopDone = true
        mField.text = to
        
        mAmountField.addTarget(self, action: #selector(checked), for: .editingChanged)
        mField.addTarget(self, action: #selector(checked), for: .editingChanged)
        
        mScan.tap({ [weak self] in
            self?.endEditing(true)
            let vc = ScannerVC()
            vc.onFound = { [weak self, weak vc] json in
                vc?.stop()
                vc?.dismiss(animated: true, completion: nil)
                self?.mField.text = json
            }
            self?.mParent?.present(vc, animated: true, completion: nil)
        })
        mCancel.click = { [weak self] in
            self?.mParent?.dismiss(animated: true, completion: nil)
        }
        mSend.click = { [weak self] in
            self?.sendTapped()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIApplication.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIApplication.keyboardWillHideNotification, object: nil)
        
        mUnits.useTopDone  = true
        mUnits.inputView   = mPicker
        mPicker.onSelected = { [weak self] token, _ in
            self?.select(token: token)
        }
        
        if let token = token {
            mName.text = "Send \(token.name)"
            mName.sizeToFit()
            mUnits.isUserInteractionEnabled = false
            mUnits.text = token.name
            mAmountField.text = token.amount.compactValue
        } else if let token = mPicker.rows.first {
            select(token: token)
        }
    }
    
    private func select(token: ETHToken) {
        mToken = token
        mUnits.text = token.name
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    @objc private func checked() {
        if let amount = Decimal(string: mAmountField.text ?? ""), mWallet.isValid(address: mField.text) != nil {
            if let token = mSelected {
                mSend.isActive = 0 < amount && amount <= token.amount
            } else {
                mSend.isActive = 0 < amount
            }
        } else {
            mSend.isActive = false
        }
    }
    
    func layout(width: CGFloat, origin: CGPoint) {
        mName.origin = CGPoint(x: (width - mName.width)/2.0, y: 0)
        mSendTo.origin = CGPoint(x: (width - mSendTo.width)/2.0, y: mName.maxY + Style.Dims.middle)
        mField.frame = CGRect(x: 0, y: mSendTo.maxY + Style.Dims.small,
                              width: width - 10.scaled - mScan.width, height: Style.Dims.middle)
        mScan.origin = CGPoint(x: mField.maxX + 10.scaled, y: mField.minY)
        mAmount.origin = CGPoint(x: (width - mAmount.width)/2.0, y: mField.maxY + Style.Dims.middle)
        mAmountField.frame = CGRect(x: 0, y: mAmount.maxY + Style.Dims.small,
                                    width: width - 110.scaled, height: Style.Dims.middle)
        mUnits.frame = CGRect(x: mAmountField.maxX + 10.scaled, y: mAmountField.minY,
                              width: 100.scaled, height: Style.Dims.middle)

        let w = (width - Style.Dims.middle)/2.0
        mCancel.frame = CGRect(x: 0, y: mAmountField.maxY + Style.Dims.middle, width: w, height: Style.Dims.middle)
        mCancel.setNeedsLayout()
        mCancel.layoutIfNeeded()
        
        mSend.frame = CGRect(x: mCancel.maxX + Style.Dims.middle, y: mCancel.minY, width: mCancel.width, height: mCancel.height)
        mSend.setNeedsLayout()
        mSend.layoutIfNeeded()
        
        frame = CGRect(origin: origin, size: CGSize(width: width, height: mCancel.maxY))
    }
    
    @objc private func keyboardWillShow(_ n: Any?) {
        (n as? Notification)?.keyboard { (rect, time, curve) in
            self.mKeyboardRect = rect
            guard let field = UIResponder.currentFirst() as? UIView else { return }
            self.move(to: field, time: time, curve: curve)
        }
    }
    
    @objc private func keyboardWillHide(_ n: Any?) {
        (n as? Notification)?.keyboard { (rect, time, curve) in
            UIView.animate(withDuration: time < 0.01 ? 0.25 : time, delay: 0.0, options: UIView.AnimationOptions(rawValue: curve << 16), animations: {
                self.mParent?.content.transform = .identity
            }, completion: nil)
        }
    }
    
    private func move(to field: UIView, time: TimeInterval, curve: UInt) {
        guard let w = self.window else { return }
        guard let k = mKeyboardRect else { return }
        guard let v = mParent?.content else { return }
        let t = v.transform
        v.transform = .identity
        let f = w.convert(field.bounds, from: field)
        v.transform = t
        if f.maxY > k.minY {
            UIView.animate(withDuration: time < 0.01 ? 0.25 : time, delay: 0.0, options: UIView.AnimationOptions(rawValue: curve << 16), animations: {
                v.transform = CGAffineTransform(translationX: 0, y: k.minY-f.maxY - 10.scaled)
            }, completion: nil)
        }
    }
    
    private func sendTapped() {
        guard mToken == nil else {
            sendTapped2()
            return
        }
        
        guard let token = mSelected else {
            mUnits.shake()
            return
        }

        if let amount = Decimal(string: mAmountField.text ?? ""), let to = mWallet.isValid(address: mField.text)?.trimmed, to.count > 0, amount > 0 {
            let hud = mParent?.view.hud
            mWallet.sendTokens(to: to, amount: amount, token: token) { [weak self] (tx) in
                hud?.hide(animated: true)
                if let tx = tx {
                    let qr = QRView(name: "success".loc, value: tx)
                    self?.mParent?.update(view: qr, configure: { [weak self] in
                        self?.mParent?.put("share".loc, do: { _ in
                            AppDelegate.share(image: qr.image, text: qr.value)
                        })
                    })
                    NotificationCenter.default.post(name: .coinsSent, object: self?.mWallet.id)
                } else {
                    "cant_send_tx".loc.show()
                }
            }
        } else {
            mSend.shake()
        }
    }
    
    private func sendTapped2() {
        guard let token = mToken else {
            mUnits.shake()
            return
        }
        guard let wallet = mWallet as? ETHWallet else { return }

        if let amount = Decimal(string: mAmountField.text ?? ""), let to = mWallet.isValid(address: mField.text)?.trimmed, to.count > 0, amount > 0 {
            let hud = mParent?.view.hud
            wallet.sendTokens(to: to, amount: amount.description, token: token.token) { [weak self] (tx) in
                hud?.hide(animated: true)
                if let tx = tx {
                    let qr = QRView(name: "success".loc, value: tx)
                    self?.mParent?.update(view: qr, configure: { [weak self] in
                        self?.mParent?.put("share".loc, do: { _ in
                            AppDelegate.share(image: qr.image, text: qr.value)
                        })
                    })
                    NotificationCenter.default.post(name: .coinsSent, object: self?.mWallet.id)
                } else {
                    "cant_send_tx".loc.show()
                }
            }
        } else {
            mSend.shake()
        }
    }
    
    // MARK:- UITextFieldDelegate methods
    // -------------------------------------------------------------------------
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == mField {
            mAmountField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return false
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if UIResponder.currentFirst() != nil {
            self.move(to: textField, time: 0.25, curve: 7)
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == mAmountField {
            var val = textField.text ?? ""
            if let r = Range(range, in: val) {
                val.replaceSubrange(r, with: string)
                let tmp = NumberFormatter()
                tmp.decimalSeparator = "."
                return val.count == 0 || tmp.number(from: val) != nil
            }
        }
        return true
    }
    
}
