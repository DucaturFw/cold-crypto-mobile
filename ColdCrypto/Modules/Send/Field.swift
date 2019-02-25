//
//  Field.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 06/12/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import UIKit

class Field: UITextField {
    
    @IBInspectable var isPasteEnabled: Bool = true
    
    @IBInspectable var isSelectEnabled: Bool = true
    
    @IBInspectable var isSelectAllEnabled: Bool = true
    
    @IBInspectable var isCopyEnabled: Bool = true
    
    @IBInspectable var isCutEnabled: Bool = true
    
    @IBInspectable var isDeleteEnabled: Bool = true

    var useTopDone = false {
        didSet {
            if useTopDone {
                let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 0, height: 44))
                toolbar.items = [
                    UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
                    UIBarButtonItem(title: "done".loc, style: .done, target: self, action: #selector(doneTapped))
                ]
                inputAccessoryView = toolbar
            } else {
                inputAccessoryView = nil
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        returnKeyType = .search
        autocorrectionType = .no
        autocapitalizationType = .none
        backgroundColor = Style.Colors.light
        layer.cornerRadius = Style.Dims.middle/2.0
        leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        leftViewMode = .always
        font = UIFont.medium(13)
        textColor = Style.Colors.black
        layer.borderColor = Style.Colors.darkGrey.cgColor
        layer.borderWidth = 2.scaled
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    @objc private func doneTapped() {
        endEditing(true)
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        switch action {
        case #selector(UIResponderStandardEditActions.paste(_:)) where !isPasteEnabled,
             #selector(UIResponderStandardEditActions.select(_:)) where !isSelectEnabled,
             #selector(UIResponderStandardEditActions.selectAll(_:)) where !isSelectAllEnabled,
             #selector(UIResponderStandardEditActions.copy(_:)) where !isCopyEnabled,
             #selector(UIResponderStandardEditActions.cut(_:)) where !isCutEnabled,
             #selector(UIResponderStandardEditActions.delete(_:)) where !isDeleteEnabled:
            return false
        default:
            return super.canPerformAction(action, withSender: sender)
        }
    }
    
}
