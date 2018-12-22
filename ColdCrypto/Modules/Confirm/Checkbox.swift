//
//  Checkbox.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 24/10/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import UIKit

class Checkbox : UIView {
    
    private let mName  = UILabel.new(font: UIFont.medium(15.scaled), lines: 0, color: Style.Colors.black, alignment: .left)
    private let mValue = UILabel.new(font: UIFont.bold(15.scaled), lines: 0, color: Style.Colors.darkGrey, alignment: .left)
    private let mCheck = UIImageView(image: UIImage(named: "checkOff"))
    
    var onChecked: (Bool)->Void = { _ in }
    
    var isChecked: Bool = false {
        didSet {
            mCheck.image = UIImage(named: isChecked ? "checkOn" : "checkOff")
            onChecked(isChecked)
        }
    }
    
    init(name: String, value: String) {
        super.init(frame: CGRect.zero)
        mName.text = name
        mName.sizeToFit()
        
        mValue.text = value
        
        addSubview(mName)
        addSubview(mValue)
        addSubview(mCheck)
        
        tap({ [weak self] in
            if let s = self {
                s.isChecked = !s.isChecked
            }
        })
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        mName.origin = .zero
        mCheck.frame = CGRect(x: 0, y: 30.scaled, width: 50.scaled, height: 50.scaled)
        
        let l = 70.scaled
        let h = mValue.text?.heightFor(width: width - l, font: mValue.font) ?? 0

        mValue.frame = CGRect(x: l, y: mCheck.minY + (mCheck.height - h)/2.0,
                              width: width - l, height: h)
    }
    
}
