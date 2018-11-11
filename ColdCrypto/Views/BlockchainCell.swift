//
//  BlockchainCell.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 08/11/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import UIKit

class BlockchainCell: UITableViewCell {
    
    let img = UIImageView().apply({
        $0.contentMode = .center
    })
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        addSubview(img)
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        img.frame = bounds
    }
    
}
