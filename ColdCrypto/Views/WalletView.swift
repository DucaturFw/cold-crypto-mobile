//
//  WalletView.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 26/10/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import UIKit
import BlockiesSwift

class WalletView: UICollectionViewCell {
    
    private let mIcon = UIImageView(image: UIImage(named: "ethIcon"))
    
    private let mContent = UIImageView(image: UIImage(named: "cardBG")).apply({
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.white.cgColor
        $0.layer.cornerRadius = 10.scaled
        $0.isUserInteractionEnabled = true
    })
    
    private let mTint = UIView().apply({
        $0.backgroundColor = UIColor.black.withAlphaComponent(0.15)
    })
    
    var fullVisible: Bool = false {
        didSet {
            mDelete.isUserInteractionEnabled = fullVisible
            mBackup.isUserInteractionEnabled = fullVisible
            mDelete.alpha = fullVisible ? 1.0 : 0.0
            mBackup.alpha = fullVisible ? 1.0 : 0.0
            let s = width / (width - 12)
            mContent.transform = fullVisible ? CGAffineTransform(scaleX: s, y: s) : .identity
        }
    }
    
    private let mAmount = UILabel.new(font: UIFont.hnMedium(28.scaled), text: "0", lines: 1, color: .white, alignment: .left)
    private let mUnits  = UILabel.new(font: UIFont.hnMedium(22.scaled), text: "FTM", lines: 1, color: .white, alignment: .left)
    private let mAddress = UILabel.new(font: UIFont.hnMedium(22.scaled), lines: 1, color: .white, alignment: .left)
    
    var onBackUp: (IWallet)->Void = { _ in }
    var onDelete: (IWallet)->Void = { _ in }
    
    private let mBackup = Button().apply({
        $0.setTitleColor(UIColor.white, for: .normal)
        $0.backgroundColor = 0xFFD136.color
        $0.setTitle("backup".loc, for: UIControlState.normal)
        $0.isUserInteractionEnabled = false
        $0.alpha = 0.0
    })
    
    private let mDelete = Button().apply({
        $0.setTitleColor(UIColor.white, for: .normal)
        $0.backgroundColor = 0xE26E7C.color
        $0.setTitle("delete".loc, for: UIControlState.normal)
        $0.isUserInteractionEnabled = false
        $0.alpha = 0.0
    })
    
    var wallet: IWallet? {
        didSet {
            mAddress.text = wallet?.address
            if let seed = mAddress.text {
                let b = Blockies(seed: seed, size: 8, scale: 3,
                                 color: 0x63DBF6.color,
                                 bgColor: 0x0089E6.color,
                                 spotColor: 0xD6F5FD.color)
                mContent.image = b.createImage(customScale: 20)
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(mContent)
        mContent.addSubview(mTint)
        mContent.addSubview(mIcon)
        mContent.addSubview(mAddress)
        mContent.addSubview(mUnits)
        mContent.addSubview(mAmount)
        mContent.addSubview(mBackup)
        mContent.addSubview(mDelete)
        mBackup.tap({ [weak self] in
            if let s = self, let w = s.wallet {
                s.onBackUp(w)
            }
        })
        mDelete.tap({ [weak self] in
            if let s = self, let w = s.wallet {
                s.onDelete(w)
            }
        })
    }

    required init?(coder aDecoder: NSCoder) {
        return nil
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        let old = mContent.transform
        mContent.transform = .identity
        mContent.frame = bounds.insetBy(dx: 6, dy: 6)

        mTint.frame  = mContent.bounds
        mIcon.origin = CGPoint(x: mContent.width - 11.scaled - mIcon.width, y: 14.scaled)
        
        mAmount.sizeToFit()
        mAmount.origin = CGPoint(x: 19.scaled, y: 14.scaled)
        mUnits.origin  = CGPoint(x: mAmount.maxX + 4.scaled, y: mAmount.maxY + mAmount.font.descender - mUnits.height - mUnits.font.descender)
        mAddress.frame = CGRect(x: 22.scaled, y: mAmount.maxY + 7.scaled, width: mIcon.minX - 32.scaled, height: mAddress.font.lineHeight)
        
        let p = 15.scaled
        let w = (mContent.width - p * 3)/2.0
        mDelete.frame = CGRect(x: p, y: mContent.height - 74.scaled, width: w, height: 64.scaled)
        mBackup.frame = CGRect(x: mDelete.maxX + p, y: mDelete.minY, width: w, height: mDelete.height)
        
        mContent.transform = old
    }

}
