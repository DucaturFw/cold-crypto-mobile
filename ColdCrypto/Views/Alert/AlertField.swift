//
//  AlertField.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 11/11/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import UIKit

class AlertField: Field, IAlertView, UITextFieldDelegate {
    
    func sizeFor(width: CGFloat) -> CGSize {
        return CGSize(width: width, height: 45)
    }
    
    func focusAtStart() {
        field.becomeFirstResponder()
    }
    
    var value: String {
        return (field.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
    }

    init() {
        super.init(name: "")
        field.returnKeyType = .done
        field.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    // MARK:- UITextFieldDelegate methods
    // -------------------------------------------------------------------------
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return false
    }
    
}
