//
//  NetworkCell.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 18/12/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import UIKit

class NetworkCell: UICollectionViewCell {
    
    private let mLabel = UILabel.new(font: .medium(15.scaled),
                                     lines: 1,
                                     color: .white,
                                     alignment: .center).apply({
                                        $0.backgroundColor = 0x736C82.color
                                        $0.layer.masksToBounds = true
                                     })
    
    var network: INetwork? {
        didSet {
            mLabel.text = network?.name ?? ""
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(mLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        mLabel.frame = bounds
        mLabel.layer.cornerRadius = mLabel.height/2.0
    }
    
}
