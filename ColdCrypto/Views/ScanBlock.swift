//
//  ScanButton.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 21/10/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import UIKit

class ScanBlock: UIView {
    
    private let mMore = UIImageView(image: UIImage(named: "dots")).apply({
        $0.contentMode = .center
        $0.backgroundColor = Style.Colors.darkGrey
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius  = Style.Dims.buttonMiddle/2.0
    })
    
    private let mScan = Button().apply({
        $0.setTitleColor(Style.Colors.white, for: .normal)
        $0.backgroundColor = Style.Colors.blue
        $0.setTitle("scan".loc, for: .normal)
    })

    var onScan: ()->Void = {}
    var onMore: ()->Void = {}
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(mScan)
        addSubview(mMore)
        mMore.tap({ [weak self] in
            self?.onMore()
        })
        mScan.tap({ [weak self] in
            self?.onScan()
        })
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        mMore.frame = CGRect(x: 40.scaled, y: 80.scaled, width: Style.Dims.buttonMiddle, height: Style.Dims.buttonMiddle)
        mScan.frame = CGRect(x: mMore.maxX + 20.scaled, y: mMore.minY, width: width - 60.scaled - mMore.maxX, height: mMore.height)
    }
    
}
