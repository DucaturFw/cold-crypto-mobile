//
//  EOSForm.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 02/12/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import UIKit

class EOSForm: UIView, ImportFieldDelegate, IWithValue {
    
    private let mCaption = UILabel.new(font: UIFont.medium(25.scaled), text: "enter_seed_pk".loc, lines: 0, color: Style.Colors.black, alignment: .center)
    
    private let mNoAcc = UILabel.new(font: UIFont.regular(16),
                                     text: "no_acccount_eos".loc,
                                     lines: 1,
                                     color: .black,
                                     alignment: .center).apply({ $0.alpha = 0.0 })
    
    private lazy var mField = ImportField(delegate: self).apply {
        $0.searchVisible = true
    }
    
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
            return mField.value
        }
        set {
            mField.value = newValue
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
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        mCaption.origin = CGPoint(x: (width - mCaption.width)/2.0, y: 0)
        mField.frame = CGRect(x: 0, y: mCaption.maxY + 30.scaled, width: width, height: Style.Dims.middle)
        mNoAcc.origin = CGPoint(x: (width - mNoAcc.width)/2.0, y: mField.maxY + 30.scaled)
        mList.frame = CGRect(x: 0, y: mField.maxY + 30.scaled, width: width, height: mList.height)
        frame.size.height = mNoAcc.alpha > 0 ? mNoAcc.maxY : mList.maxY
    }

    func shakeField() {
        mField.shake()
    }
    
    @objc private func hideKB() {
        mField.resignFirstResponder()
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

    // MARK: - ImportFieldDelegate methods
    // -------------------------------------------------------------------------
    func onScan(from: ImportField) {
        onScan()
    }
    
    func onReturn(from: ImportField) -> Bool {
        if onSearch(from.value) {
            mField.endEditing(true)
        }
        return false
    }
    
    func onChanged(from: ImportField) {}
    
    func onSearch(from: ImportField) {
        let _ = onSearch(from.value)
        endEditing(true)
    }
    
}
