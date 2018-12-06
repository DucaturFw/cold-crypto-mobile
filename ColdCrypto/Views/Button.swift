//
//  Button.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 20/10/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import UIKit

class Button : UIButton {
    
    var click: ()->Void = {}
    
    private var mOldBackgroundColor: UIColor?
    var isActive: Bool = true {
        didSet {
            if oldValue != isActive {
                if !isActive {
                    mOldBackgroundColor = backgroundColor
                }
                backgroundColor = isActive ? mOldBackgroundColor : Style.Colors.darkLight
                isUserInteractionEnabled = isActive
                
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = Style.Dims.small
        setTitleColor(Style.Colors.white, for: .normal)
        titleLabel?.font = .medium(15.scaled)
        addTarget(self, action: #selector(clicked), for: .touchUpInside)
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    private var mDelay = false
    
    @objc private func clicked() {
        if !mDelay {
            mDelay = true
            addTint(completion: { [weak self] in
                self?.mDelay = false
                self?.isUserInteractionEnabled = true
                self?.click()
            })
        }
    }
    
}
