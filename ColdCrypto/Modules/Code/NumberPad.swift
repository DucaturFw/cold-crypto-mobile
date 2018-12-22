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
            let key = Button(frame: CGRect(x: (i == 9 ? 1 : CGFloat(i % 3)) * 100.scaled, y: CGFloat(i / 3) * 100.scaled, width: 78.scaled, height: 78.scaled))
            key.titleLabel?.font = .regular(36.scaled)
            key.setTitleColor(Style.Colors.black, for: .normal)
            key.setTitle("\((i+1)%10)", for: .normal)
            key.backgroundColor = Style.Colors.white
            key.layer.borderWidth = 4.scaled
            key.layer.borderColor = Style.Colors.black.alpha(0.5).cgColor
            key.layer.cornerRadius = 39.scaled
            key.click = { [weak self] in
                self?.onClick((i+1)%10)
            }
            tmp.append(key)
        }
        return tmp
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        alpha = 0.6
        mKeys.forEach({
            $0.titleEdgeInsets = UIEdgeInsets(top: 2.scaled, left: 0, bottom: 0, right: 0)
            self.addSubview($0)
        })
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
}
