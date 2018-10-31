//
//  ChainPicker.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 21/10/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import UIKit

class WalletPicker: UIScrollView {
    
    private var mViews = [WalletView]()
    
    var count: Int {
        return mViews.count
    }
    
    var onTap: (IWallet)->Void = { _ in }
    
    init(profile: Profile) {
        super.init(frame: .zero)
        isPagingEnabled = true        
//        profile.chains.forEach({
//            $0.wallets.forEach({ w in
//                WalletView(wallet: w).apply({
//                    mViews.append($0)
//                    addSubview($0)
//                    $0.tap({ [weak self] in self?.onTap(w) })
//                })
//            })
//        })
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        var l: CGFloat = 0.0
        mViews.forEach({
            $0.frame = CGRect(x: l, y: 0.0, width: width, height: height)
            l = $0.maxX
        })
        contentSize = CGSize(width: l, height: 0)
    }
    
    func append(wallet: IWallet) {
//        WalletView(wallet: wallet).apply({
//            mViews.append($0)
//            addSubview($0)
//            $0.tap({ [weak self] in self?.onTap(wallet) })
//        })
//        setNeedsLayout()
//        layoutIfNeeded()
//        setContentOffset(CGPoint(x: contentSize.width - width, y: 0), animated: true)
    }
    
}
