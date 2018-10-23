//
//  ScanButton.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 21/10/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import UIKit

class ScanButton: UIView {
    
    private let mIcon = UIImageView(image: UIImage(named: "qrIcon"))
    
    private let mText = UILabel.new(font: UIFont.hnMedium(18.scaled), text: "scan".loc, lines: 1, color: .white, alignment: .center)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = 0x007AFF.color
        layer.cornerRadius = 29.scaled
        addSubview(mIcon)
        addSubview(mText)
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let w = mIcon.width + ceil(7.scaled) + mText.width
        mIcon.origin = CGPoint(x: (width - w)/2.0, y: (height - mIcon.height)/2.0)
        mText.origin = CGPoint(x: mIcon.maxX + ceil(7.scaled), y: (height - mText.height)/2.0)
    }
    
}
