//
//  MenuCell.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 03/11/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import UIKit

class MenuCell: UITableViewCell {
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle  = .none
        textLabel?.font = UIFont.hnMedium(16)
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
}
