//
//  ChainPicker.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 21/10/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import UIKit

class ChainPicker: UIScrollView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.borderWidth = 1.0
        layer.borderColor = UIColor.red.cgColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
}
