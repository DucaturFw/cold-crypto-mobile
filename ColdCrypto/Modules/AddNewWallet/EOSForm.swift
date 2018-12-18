//
//  EOSForm.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 02/12/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import UIKit

class EOSForm: UIView, UITextFieldDelegate, IWithValue {
    
    private let mCaption = UILabel.new(font: UIFont.medium(25.scaled), text: "enter_seed_pk".loc, lines: 0, color: Style.Colors.black, alignment: .center)
    
    private let mNoAcc = UILabel.new(font: UIFont.regular(16),
                                     text: "no_acccount_eos".loc,
                                     lines: 1,
                                     color: .black,
                                     alignment: .center).apply({ $0.alpha = 0.0 })
    
    private lazy var mField = UITextField().apply({ [weak self] in
        $0.returnKeyType = .search
        $0.autocorrectionType = .no
        $0.autocapitalizationType = .none
        $0.backgroundColor = Style.Colors.light
        $0.layer.cornerRadius = Style.Dims.middle/2.0
        $0.layer.borderWidth = 0.0
        $0.delegate = self
        $0.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        $0.leftViewMode = .always
        $0.font = UIFont.medium(13)
        $0.textColor = Style.Colors.black
    })
    
    var onValid: (Bool)->Void = { _ in }
    var onScan: ()->Void = {}
    var onSearch: (String)->Bool = { _ in return true }
    
    private(set) var isValid: Bool = false {
        didSet {
            onValid(isValid)
        }
    }

    private(set) var privateKey: String?
    
    private(set) var selected: String?
    
    private var mList = AccountPicker(accounts: [])
    
    var value: String {
        get {
            return (mField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        }
        set {
            mField.text = newValue
            if newValue.count > 0 {
                let _ = onSearch(newValue)
                endEditing(true)
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(mCaption)
        addSubview(mField)
        addSubview(mNoAcc)
        addSubview(mList)
        mField.rightView = UIImageView(image: UIImage(named: "scanIcon")).apply({
            $0.contentMode = .center
            $0.transform = CGAffineTransform(rotationAngle: CGFloat.pi/2.0)
            $0.frame = $0.frame.insetBy(dx: -15, dy: -15)
        }).tap({ [weak self] in
            self?.onScan()
        })
        mField.rightViewMode = .always
        mField.attributedPlaceholder = NSAttributedString(string: "your_pk".loc,
                                                          attributes: [.font: UIFont.medium(13), .foregroundColor: Style.Colors.darkLight])
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        mCaption.origin = CGPoint(x: (width - mCaption.width)/2.0, y: 0)
        mField.frame = CGRect(x: 40.scaled, y: mCaption.maxY + 30.scaled, width: width - 80.scaled, height: Style.Dims.middle)
        mNoAcc.origin = CGPoint(x: (width - mNoAcc.width)/2.0, y: mField.maxY + 30.scaled)
        mList.frame = CGRect(x: 40.scaled, y: mField.maxY + 30.scaled, width: width - 80.scaled, height: mList.height)
        frame.size.height = mNoAcc.alpha > 0 ? mNoAcc.maxY : mList.maxY
    }

    func shakeField() {
        mField.shake()
    }
    
    func update(pk: String, accounts: [String], completion: @escaping ()->Void) {
        privateKey = pk
        isValid = false
        selected = nil
        onValid(false)
        AppDelegate.lock()
        UIView.animate(withDuration: 0.25, animations: {
            self.mList.alpha = 0.0
        }, completion: { _ in
            self.appear(accounts: accounts, completion: completion)
        })
    }
    
    private func appear(accounts: [String], completion: @escaping ()->Void) {
        mList.removeFromSuperview()
        mList = AccountPicker(accounts: accounts)
        mList.alpha = 0
        mList.frame = CGRect(x: 40.scaled, y: mField.maxY + 30.scaled, width: width - 80.scaled, height: mList.height)
        mList.onPicked = { [weak self] p in
            self?.selected = p
            self?.onValid(true)
        }
        addSubview(mList)
        UIView.animate(withDuration: 0.25, animations: {
            self.mNoAcc.alpha = accounts.count == 0 ? 1.0 : 0.0
            self.mList.alpha = 1.0
            self.setNeedsLayout()
            self.layoutIfNeeded()
            completion()
        }, completion: { (_) in
            AppDelegate.unlock()
        })
    }

    // MARK: - UITextFieldDelegate methods
    // -------------------------------------------------------------------------
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if onSearch(mField.text ?? "") {
            mField.endEditing(true)
        }
        return false
    }
    
}
