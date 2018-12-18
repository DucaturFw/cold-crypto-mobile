//
//  CryptoItem.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 25/11/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import UIKit

class CryptoItem: UIView {
    
    static let width:  CGFloat = 60.scaled
    static let height: CGFloat = 60.scaled
    
    private let mIcon: UIImageView = UIImageView().apply({
        $0.contentMode = .scaleAspectFit
    })
    
    let blockchain: Blockchain
    
    private var mSelected = false
    var selected: Bool {
        set {
            mSelected = newValue
            mIcon.tintColor = mSelected ? Style.Colors.blue : Style.Colors.darkGrey
        }
        get {
            return mSelected
        }
    }
    
    override var frame: CGRect {
        get {
            var tmp = super.frame
            tmp.size = CGSize(width: CryptoItem.width, height: CryptoItem.height)
            return tmp
        }
        set {
            var tmp = newValue
            tmp.size = CGSize(width: CryptoItem.width, height: CryptoItem.height)
            super.frame = tmp
        }
    }
    
    init(blockchain: Blockchain) {
        self.blockchain = blockchain
        super.init(frame: CGRect(x: 0, y: 0, width: CryptoItem.width, height: CryptoItem.height))
        mIcon.image = blockchain.icon().withRenderingMode(.alwaysTemplate)
        addSubview(mIcon)
        selected = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        mIcon.frame = bounds
    }
    
}
