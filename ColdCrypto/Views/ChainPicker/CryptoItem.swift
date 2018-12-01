//
//  CryptoItem.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 25/11/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import UIKit

class CryptoItem: UIView {
    
    static let width:  CGFloat = 95.scaled
    static let height: CGFloat = 65.scaled
    
    private let mIcon: UIImageView = {
        let tmp = UIImageView(frame: CGRect(x: 0, y: 0, width: 26.scaled, height: 26.scaled))
        tmp.contentMode = .scaleAspectFit
        return tmp
    }()
    
    private let mName: UILabel = UILabel.new(font: UIFont.sfProSemibold(12.scaled), lines: 1, color: 0x32325D.color, alignment: .center)
    
    let blockchain: Blockchain
    
    private var mSelected = false
    var selected: Bool {
        set {
            mSelected = newValue
            layer.borderWidth = mSelected ? 1.0 : 0.0
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
        layer.cornerRadius  = 4
        layer.shadowColor   = 0x44519E.color.cgColor
        layer.shadowOpacity = 0.15
        layer.shadowOffset = CGSize(width: 0, height: 10.scaled)
        layer.shadowRadius = 10
        layer.borderColor  = Style.Colors.blue.cgColor
        backgroundColor = Style.Colors.white
        
        mIcon.image = blockchain.icon()
        mName.text  = blockchain.name()
        
        addSubview(mIcon)
        addSubview(mName)
        
        tap({ [weak self] in
            self?.backgroundColor = Style.Colors.white.darker()
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + DispatchTimeInterval.milliseconds(100), execute: {
                self?.backgroundColor = Style.Colors.white
            })
        })
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        mIcon.origin = CGPoint(x: (width - mIcon.width)/2.0, y: floor(10.scaled))
        mName.frame  = CGRect(x: 5.scaled, y: floor(mIcon.maxY + 5.scaled), width: width - 10.scaled, height: mName.font.lineHeight)
    }
    
}
