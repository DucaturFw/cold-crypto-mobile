//
//  CryptoList.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 25/11/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import UIKit

class ChainPicker: UIView {
    
    private var mIsCollapsed = false
    
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
    }
    
    required init?(coder: NSCoder) {
        return nil
    }
    
    private func select(index: Int) {
        mItems.enumerated().forEach { i in
            let s = i.element.selected
            i.element.selected = index == i.offset
            if i.element.selected && !s {
                onSelect(i.element.blockchain)
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let gg = 15.scaled
        
        let w  = width - gg
        let iw = CryptoItem.width + gg
        
        let h = Int(floor(w / iw))
        let v = (mItems.count - mItems.count % h) / h + 1
        
        let p = (width - CGFloat(h) * CryptoItem.width) / CGFloat(h + 1)
        
        var y = CGFloat(0)
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
            if mIsCollapsed && $0.element.selected {
                $0.element.origin = CGPoint(x: (width - $0.element.width)/2.0, y: 0)
                $0.element.alpha  = 1.0
            } else {
                $0.element.alpha = mIsCollapsed ? 0.0 : 1.0
            }
        })
        frame.size.height = mIsCollapsed ? CryptoItem.height : (mItems.last?.maxY ?? 0)
    }
    
    func collapse() {
        mIsCollapsed = true
    }
    
}

