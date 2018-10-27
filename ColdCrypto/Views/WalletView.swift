//
//  WalletView.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 26/10/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import UIKit

class WalletView: UIView {
    
    private let mIcon = UIImageView(image: UIImage(named: "ethIcon"))
    
    private let mContent = UIImageView(image: UIImage(named: "cardBG")).apply({
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.white.cgColor
        $0.layer.cornerRadius = 10.scaled
    })
    
    private let mAmount = UILabel.new(font: UIFont.hnMedium(28.scaled), text: "0", lines: 1, color: .white, alignment: .left)
    private let mUnits  = UILabel.new(font: UIFont.hnMedium(22.scaled), text: "FTM", lines: 1, color: .white, alignment: .left)
    private let mHint   = UILabel.new(font: .hnMedium(16.scaled), text: "wallet_hint".loc, lines: 1, color: 0xFFFFFF.color.withAlphaComponent(0.6), alignment: .left)
    private let mAddress = UILabel.new(font: UIFont.hnMedium(22.scaled), lines: 0, color: .white, alignment: .left)
    
    private let mHint2 = UILabel.new(font: UIFont.hnMedium(12),
                                     text: "$0.00 USD @ $208.14/FTM",
                                     lines: 1,
                                     color: UIColor.white.withAlphaComponent(0.6),
                                     alignment: .left)
    
    init(wallet: IWallet) {
        super.init(frame: .zero)
        addSubview(mContent)
        mContent.addSubview(mIcon)
        mContent.addSubview(mHint)
        mContent.addSubview(mAddress)
        mContent.addSubview(mUnits)
        mContent.addSubview(mAmount)
        mContent.addSubview(mHint2)
        mAddress.text = wallet.address
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        mContent.frame = self.bounds.insetBy(dx: 6, dy: 6)
        mIcon.origin = CGPoint(x: mContent.width - 11.scaled - mIcon.width, y: 14.scaled)
        
        mAmount.sizeToFit()
        mAmount.origin = CGPoint(x: 19.scaled, y: 14.scaled)
        mUnits.origin  = CGPoint(x: mAmount.maxX + 4.scaled, y: mAmount.maxY + mAmount.font.descender - mUnits.height - mUnits.font.descender)
        mHint2.origin  = CGPoint(x: 22.scaled, y: mAmount.maxY + 4.scaled)
        mHint.origin   = CGPoint(x: 22.scaled, y: mAmount.maxY + 24.scaled)
        let h = mAddress.text?.heightFor(width: mContent.width - 44.scaled,
                                         font: mAddress.font) ?? 0
        mAddress.frame = CGRect(x: 22.scaled, y: mHint.maxY + 14.scaled,
                                width: mContent.width - 44.scaled, height: h)
    }
        
}
