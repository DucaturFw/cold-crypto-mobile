//
//  AccountCell.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 26/11/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import UIKit

class AccountCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        textLabel?.font = UIFont.regular(15)
        textLabel?.highlightedTextColor = Style.Colors.blue
        selectedBackgroundView = UIView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
}
