//
//  Field.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 06/12/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import UIKit

class Field: UITextField {
    
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
    
}
