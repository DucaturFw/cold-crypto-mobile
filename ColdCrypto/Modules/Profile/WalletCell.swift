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
    
    static let padding = Style.Dims.small

    static func cardSize(width: CGFloat) -> CGSize {
        return CGSize(width: width, height: ceil((width - 40.scaled) / 330.0 * 200.0) + padding)
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
            checkBadge()
        }
    }
    
    private let mAmount  = UILabel.new(font: UIFont.bold(20.scaled), lines: 1, color: Style.Colors.white, alignment: .left)
    private let mMoney   = UILabel.new(font: UIFont.bold(15.scaled), lines: 1, color: Style.Colors.white.alpha(0.8), alignment: .left)
    private let mAddress = UILabel.new(font: UIFont.bold(14.scaled), lines: 1, color: Style.Colors.white, alignment: .left)
    
    private let mHUD = UIActivityIndicatorView(style: .white).apply({
        $0.hidesWhenStopped = true
    })
        
    private let mOverlay = UIView().apply({
        $0.backgroundColor = UIColor.black.alpha(0.2)
    })
    
    private let mLan = UILabel.new(font: UIFont.bold(12.scaled), text: "connected".loc, lines: 1, color: .white, alignment: .center).apply({
        $0.backgroundColor = Style.Colors.green
        $0.frame = $0.frame.insetBy(dx: -4, dy: -4).integral
        $0.layer.borderWidth   = 1.0
        $0.layer.borderColor   = Style.Colors.white.cgColor
        $0.layer.cornerRadius  = $0.height/2.0
        $0.layer.masksToBounds = true
    })
    
    private var mCache = UUID().uuidString
    
    private let mLogo = UIImageView(image: UIImage(named: "eosLarge"))
    
    var wallet: IWallet? {
        didSet {
            oldValue?.onConnected = nil
            
            mAddress.text = wallet?.address
            mLogo.image   = wallet?.blockchain.largeIcon()
            mCard.image   = CardProvider.getCard(mAddress.text ?? "")
            wallet?.onConnected = { [weak self] v in
                UIView.animate(withDuration: 0.25, animations: {
                    self?.checkBadge()
                })
            }
            refreshBalance()
            checkBadge()
        }
    }
    
    private func refreshBalance() {
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
        mCard.addSubview(mLan)
        NotificationCenter.default.addObserver(self, selector: #selector(coinsSent(_:)), name: .coinsSent, object: nil)
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
            let t = mCard.transform
            let p = WalletCell.padding
            mCard.transform = .identity
            mCard.frame = CGRect(origin: .zero, size: s).insetBy(dx: Style.Dims.small, dy: p/2.0).offsetBy(dx: 0, dy: p/2.0).integral
            mCard.transform = t
        }
        
        mOverlay.frame = mCard.bounds
        mLogo.origin   = CGPoint(x: mCard.width - mLogo.width + 53, y: (mCard.height - mLogo.height)/2.0)
        mAmount.frame  = CGRect(x: 20.scaled, y: 20.scaled, width: mCard.width - 40.scaled, height: mAmount.font.lineHeight)
        mHUD.origin    = CGPoint(x: 19.scaled, y: 14.scaled)
        mMoney.frame   = CGRect(x: 22.scaled, y: mAmount.maxY + 7.scaled, width: mCard.width - 44.scaled, height: mMoney.font.lineHeight)
        mAddress.frame = CGRect(x: 22.scaled, y: mMoney.maxY + 7.scaled, width: mCard.width - 44.scaled, height: mAddress.font.lineHeight)
        mLan.origin    = CGPoint(x: mCard.width - mLan.width - 5.scaled, y: 5.scaled)
    }
    
    @objc private func coinsSent(_ n: Any?) {
        guard let id = (n as? Notification)?.object as? String else { return }
        if id == wallet?.id {
            wallet?.flushCache()
            refreshBalance()
        }
    }
    
    private func checkBadge() {
        switch wallet?.connectionStatus {
        case .none: fallthrough
        case .some(.stop):
            mLan.text = "not_connected".loc
            mLan.backgroundColor = Style.Colors.red
        case .some(.success):
            mLan.text = "connected".loc
            mLan.backgroundColor = Style.Colors.green
        case .some(.start):
            mLan.text = "connecting".loc
            mLan.backgroundColor = Style.Colors.blue
        }
        
        mLan.sizeToFit()
        
        let w = mLan.width + 8
        let h = mLan.height + 8
        mLan.frame = CGRect(x: mCard.width - w - 5.scaled, y: 5.scaled, width: w, height: h)
        mLan.layer.cornerRadius = mLan.height/2.0
        
        let s = wallet?.connectionStatus
        
        mLan.alpha = fullVisible && (s == .start || s == .success) ? 1.0 : 0.0
    }
    
}
