//
//  Checkbox.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 24/10/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import UIKit

class Checkbox : UIView {
    
    private let mName = UILabel.new(font: UIFont.hnRegular(16.scaled), lines: 0, color: .black, alignment: .left)
    
    private let mValue = UILabel.new(font: UIFont.hnMedium(24.scaled), lines: 0, color: .black, alignment: .left)
    
    private let mCheck = UIImageView(image: UIImage(named: "checkOff"))
    
    override var frame: CGRect {
        get {
            return super.frame
        }
        set {
            var tmp = newValue
            tmp.size.height = adjustHeight(width: tmp.width)
            super.frame = tmp
        }
    }
    
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
        self.frame.size.height = adjustHeight(width: width)
    }
    
    private func adjustHeight(width: CGFloat) -> CGFloat {
        let l = 56.scaled
        mName.frame = CGRect(x: l, y: 0, width: width - l, height: mName.text?.heightFor(width: width - l, font: mName.font) ?? 0)
        mValue.frame = CGRect(x: l, y: ceil(mName.maxY), width: width - l, height: mValue.text?.heightFor(width: width - l, font: mValue.font) ?? 0)
        mCheck.frame = CGRect(x: 0, y: (mValue.maxY - 36.scaled)/2.0, width: 36.scaled, height: 36.scaled)
        return mValue.maxY
    }
    
}
