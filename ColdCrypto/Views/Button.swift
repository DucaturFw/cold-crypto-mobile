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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 12.scaled
        setTitleColor(UIColor.white, for: .normal)
        titleLabel?.font = .hnMedium(18.0.scaled)
        addTarget(self, action: #selector(clicked), for: .touchUpInside)
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    @objc private func clicked() {
        let old = self.backgroundColor
        self.backgroundColor = old?.darker()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + DispatchTimeInterval.milliseconds(100)) {
            self.backgroundColor = old
            self.click()
        }
    }
    
}
