//
//  HistoryDetails.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 16/12/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import UIKit
import QRCode

class HistoryDetails: UIView {
    
    public static let defHeight = 140.scaled
    
    private let mImage = UIImageView(frame: CGRect(x: Style.Dims.middle, y: 0, width: 120.scaled, height: 120.scaled))
    
    private let mText = UILabel.new(font: UIFont.regular(13.scaled), lines: 0, color: Style.Colors.black, alignment: .right)
    
    private let mButton = Button().apply({
        $0.backgroundColor = Style.Colors.darkGrey
        $0.setTitle("share".loc, for: .normal)
        $0.layer.cornerRadius = Style.Dims.middle/2.0
    })
    
    var transaction: ITransaction? {
        didSet {
            if let h = transaction?.hash, var qr = QRCode(h) {
                qr.size = CGSize(width: mImage.width, height: mImage.height)
                mImage.image = qr.image
            } else {
                mImage.image = nil
            }
            mText.text = transaction?.hash
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(mImage)
        addSubview(mButton)
        addSubview(mText)
        mButton.tap { [weak self] in
            AppDelegate.share(image: self?.mImage.image, text: self?.transaction?.hash ?? "")
        }
        mImage.tap { [weak self] in
            AppDelegate.share(image: self?.mImage.image, text: self?.transaction?.hash ?? "")
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let l = mImage.maxX + Style.Dims.small
        mButton.frame = CGRect(x: l, y: height - Style.Dims.small - Style.Dims.middle,
                               width: width - l - Style.Dims.middle, height: Style.Dims.middle)
        mText.frame = CGRect(x: l, y: 0, width: mButton.width, height: mButton.minY - Style.Dims.small)
    }
    
}
