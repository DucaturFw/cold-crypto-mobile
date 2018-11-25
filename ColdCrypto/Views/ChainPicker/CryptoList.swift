//
//  CryptoList.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 25/11/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import UIKit

class CryptoList: UIView {
    
    private var mItems: [CryptoItem] = Blockchain.allCases.compactMap({
        CryptoItem(blockchain: $0)
    })
    
    var onSelect: (Blockchain)->Void = { index in }
    
    var selected: Blockchain? {
        get {
            return mItems.first(where: { $0.selected })?.blockchain
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        mItems.enumerated().forEach { i in
            let idx = i.offset
            addSubview(i.element)
            i.element.tap({ [weak self] in
                self?.select(index: idx)
            })
        }
        backgroundColor = .white
        layer.cornerRadius = 10.scaled
    }
    
    required init?(coder: NSCoder) {
        return nil
    }
    
    private func select(index: Int) {
        mItems.enumerated().forEach { i in
            i.element.selected = index == i.offset
            if i.element.selected {
                onSelect(i.element.blockchain)
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let w  = width - 15.scaled
        let iw = CryptoItem.width + 15.scaled
        
        let h = Int(floor(w / iw))
        let v = (mItems.count - mItems.count % h) / h + 1
        
        let p = (width - CGFloat(h) * CryptoItem.width) / CGFloat(h + 1)
        
        var y = p + 44.0 + UIApplication.shared.statusBarFrame.height
        var i = 0
        let g = (width - CGFloat(mItems.count % h) * CryptoItem.width - CGFloat(mItems.count % h-1) * p)/2.0
        var x = (1 == v ? g : p)
        
        mItems.enumerated().forEach({
            $0.element.origin = CGPoint(x: x, y: y)
            if ($0.offset + 1) % h == 0 {
                i += 1
                x = ((i + 1) == v ? g : p)
                y = $0.element.maxY + p
            } else {
                x = $0.element.maxX + p
            }
        })
        frame.size.height = (mItems.last?.maxY ?? 0) + p
    }
    
}

