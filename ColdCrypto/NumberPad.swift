//
//  NumberPad.swift
//  MultiMask
//
//  Created by Kirill Kozhuhar on 02/08/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import UIKit

class NumberPad: UIView {
    
    override var frame: CGRect {
        get {
            var tmp = super.frame
            tmp.size = CGSize(width: 270.scaled, height: 370.scaled)
            return tmp
        }
        set {
            super.frame = CGRect(x: newValue.minX, y: newValue.minY, width: 270.scaled, height: 370.scaled)
        }
    }
    
    var onClick: (Int)->Void = { key in }
    
    private lazy var mKeys: [Button] = { [weak self] in
        var tmp: [Button] = []
        for i in 0...9 {
            let key = Button(frame: CGRect(x: (i == 9 ? 1 : CGFloat(i % 3)) * 100.scaled, y: CGFloat(i / 3) * 100.scaled, width: 70.scaled, height: 70.scaled))
            key.titleLabel?.font = .sfProRegular(24.scaled)
            key.setTitleColor(.black, for: .normal)
            key.setTitle("\((i+1)%10)", for: .normal)
            key.backgroundColor = 0xF9FAFC.color
            key.layer.borderWidth = 1.0
            key.layer.borderColor = 0xEDF0F7.color.cgColor
            key.layer.cornerRadius = 35.scaled
            key.click = { [weak self] in
                self?.onClick((i+1)%10)
            }
            tmp.append(key)
        }
        return tmp
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        mKeys.forEach({
            self.addSubview($0)
        })
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
}
