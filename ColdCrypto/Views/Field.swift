//
//  Field.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 10/11/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import UIKit

class Field : UIView {
    
    private let mName = UILabel.new(font: UIFont.sfProSemibold(14), lines: 1, color: 0xC7CCD7.color, alignment: .left)
    
    private let mField: UITextField = {
        let tmp = UITextField()
        tmp.backgroundColor = .clear
        tmp.font = UIFont.proMedium(13)
        tmp.textColor = 0x32325D.color
        return tmp
    }()
    
    var field: UITextField {
        return mField
    }
    
    override var isFirstResponder: Bool {
        return mField.isFirstResponder
    }
    
    init(name: String) {
        super.init(frame: .zero)
        mName.text = name
        mName.sizeToFit()
        addSubview(mName)
        addSubview(mField)
        
        layer.borderWidth  = 1.0
        layer.borderColor  = 0xDADBE1.color.cgColor
        layer.cornerRadius = 6
        backgroundColor    = Style.Colors.white
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        mName.origin = CGPoint(x: 0, y: -10 - mName.height)
        mField.frame = CGRect(x: 10, y: 0, width: width - 20, height: height)
    }
    
}
