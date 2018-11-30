//
//  MenuCell.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 03/11/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import UIKit

class MenuCell: UITableViewCell {
    
    private let mName = UILabel.new(font: .proMedium(18.scaled),
                                    lines: 1,
                                    color: Style.Colors.black,
                                    alignment: .left)
    
    private let mIcon = UIImageView().apply({
        $0.contentMode = .center
    })
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle  = .none
        addSubview(mName)
        addSubview(mIcon)
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        mName.sizeToFit()
        mName.origin = CGPoint(x: 84.scaled, y: (height - mName.height)/2.0)
        mIcon.frame  = CGRect(x: 22.scaled, y: 0, width: 64.scaled, height: height)
    }
    
    func set(name: String, icon: UIImage?) {
        mName.text  = name
        mIcon.image = icon
    }
    
}
