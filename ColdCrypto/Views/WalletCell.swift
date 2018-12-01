//
//  WalletView.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 26/10/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import UIKit
import BlockiesSwift

class WalletCell: UICollectionViewCell {

    static func cardSize(width: CGFloat) -> CGSize {
        return CGSize(width: width, height: ceil(width / 330.0 * 200.0))
    }
        
    private let mCard = UIImageView(image: UIImage(named: "card0")).apply({
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 10.scaled
        $0.isUserInteractionEnabled = true
    })
    var card: UIView {
        return mCard
    }
    
    var fullVisible: Bool = false {
        didSet {
            mDelete.isUserInteractionEnabled = fullVisible
            mBackup.isUserInteractionEnabled = fullVisible
            mDelete.alpha = fullVisible ? 1.0 : 0.0
            mBackup.alpha = fullVisible ? 1.0 : 0.0
        }
    }
    
    private let mAmount  = UILabel.new(font: UIFont.proBold(20.scaled), lines: 1, color: Style.Colors.white, alignment: .left)
    private let mMoney   = UILabel.new(font: UIFont.proBold(15.scaled), lines: 1, color: Style.Colors.white.alpha(0.8), alignment: .left)
    private let mAddress = UILabel.new(font: UIFont.proBold(14.scaled), lines: 1, color: Style.Colors.white, alignment: .left)
    
    private let mHUD = UIActivityIndicatorView(style: .white).apply({
        $0.hidesWhenStopped = true
    })
    
    var onBackUp: (IWallet)->Void = { _ in }
    var onDelete: (IWallet)->Void = { _ in }
    
    private let mOverlay = UIView().apply({
        $0.backgroundColor = UIColor.black.alpha(0.2)
    })
    
    private let mBackup = Button().apply({
        $0.setTitleColor(Style.Colors.white, for: .normal)
        $0.backgroundColor = Style.Colors.darkGrey
        $0.setTitle("backup".loc, for: .normal)
        $0.isUserInteractionEnabled = false
        $0.alpha = 0.0
    })
    
    private let mDelete = Button().apply({
        $0.setTitleColor(Style.Colors.white, for: .normal)
        $0.backgroundColor = Style.Colors.darkGrey
        $0.setTitle("delete".loc, for: .normal)
        $0.isUserInteractionEnabled = false
        $0.alpha = 0.0
    })
    
    private var mCache = UUID().uuidString
    
    private let mLogo = UIImageView(image: UIImage(named: "eosLarge"))
    
    var wallet: IWallet? {
        didSet {
            mAddress.text = wallet?.address
            mLogo.image   = wallet?.blockchain.largeIcon()
            mCard.image   = CardProvider.getCard(mAddress.text ?? "")

            mHUD.startAnimating()
            let cache = UUID().uuidString
            let units = wallet?.blockchain.symbol() ?? ""
            mCache = cache
            
            mMoney.text  = ""
            mAmount.text = ""
            wallet?.getBalance(completion: { [weak self] b, r in
                if let s = self, cache == s.mCache {
                    s.mAmount.isHidden = false
                    s.mHUD.stopAnimating()
                    s.mAmount.text = "\(b ?? "--") \(units)"
                    s.mMoney.text = "\(r ?? "--") USD"
                }
            })
        }
    }
    
    override var withTint: Bool {
        return false
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(mCard)
        mCard.addSubview(mOverlay)
        mCard.addSubview(mLogo)
        mCard.addSubview(mAddress)
        mCard.addSubview(mAmount)
        mCard.addSubview(mMoney)
        mCard.addSubview(mHUD)
        mCard.addSubview(mBackup)
        mCard.addSubview(mDelete)

        mBackup.click = { [weak self] in
            if let s = self, let w = s.wallet {
                s.onBackUp(w)
            }
        }
        mDelete.click = { [weak self] in
            if let s = self, let w = s.wallet {
                s.onDelete(w)
            }
        }
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if !fullVisible {
            return mCard.point(inside: convert(point, to: mCard), with: event)
        }
        return super.point(inside: point, with: event)
    }

    required init?(coder aDecoder: NSCoder) {
        return nil
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if mCard.superview == self {
            let s = WalletCell.cardSize(width: width)
            let i = 23.scaled
            
            let t = mCard.transform
            mCard.transform = .identity
            mCard.frame = CGRect(origin: .zero, size: s).insetBy(dx: i, dy: i)
            mCard.transform = t
        }
        
        mOverlay.frame = mCard.bounds
        mLogo.origin   = CGPoint(x: mCard.width - mLogo.width + 53, y: (mCard.height - mLogo.height)/2.0)
        mAmount.frame  = CGRect(x: 20.scaled, y: 20.scaled, width: mCard.width - 40.scaled, height: mAmount.font.lineHeight)
        mHUD.origin    = CGPoint(x: 19.scaled, y: 14.scaled)
        mMoney.frame   = CGRect(x: 22.scaled, y: mAmount.maxY + 7.scaled, width: mCard.width - 44.scaled, height: mMoney.font.lineHeight)
        mAddress.frame = CGRect(x: 22.scaled, y: mMoney.maxY + 7.scaled, width: mCard.width - 44.scaled, height: mAddress.font.lineHeight)
        
        let p = 20.scaled
        let w = (mCard.width - p * 3)/2.0
        let y = mCard.height - Style.Dims.buttonMiddle - 20.scaled
        
        mDelete.frame = CGRect(x: p, y: y, width: w, height: Style.Dims.buttonMiddle)
        mBackup.frame = CGRect(x: mDelete.maxX + p, y: mDelete.minY, width: w, height: mDelete.height)
    }
    
}
