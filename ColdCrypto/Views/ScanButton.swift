//
//  ScanButton.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 06/12/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import UIKit

class ScanButton: UIImageView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = Style.Colors.darkGrey
        layer.masksToBounds = true
        image = UIImage(named: "scanWhite")
        contentMode = .center
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = width/2.0
    }
    
}
