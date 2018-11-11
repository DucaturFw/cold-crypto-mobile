//
//  SeedWord.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 12/11/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import UIKit

class SeedWord: UIView {
    
    private let mWord: UILabel
    private let mIndex: UILabel
    
    init(index: Int, word: String) {
        mWord  = UILabel.new(font: UIFont.hnBold(14), text: word, lines: 1, color: .black, alignment: .left)
        mIndex = UILabel.new(font: UIFont.hnBold(14), text: "\(index)", lines: 1, color: UIColor.black.withAlphaComponent(0.4), alignment: .left)
        super.init(frame: CGRect(x: 0, y: 0, width: mIndex.width + mWord.width, height: mWord.height))
        addSubview(mWord)
        addSubview(mIndex)
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        mIndex.frame = CGRect(x: 0, y: 0, width: 20, height: mIndex.height)
        mWord.frame  = CGRect(x: mIndex.maxX, y: 0, width: mWord.width, height: mWord.height)
    }
    
}
