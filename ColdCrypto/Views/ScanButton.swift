//
//  ScanButton.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 21/10/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import UIKit

class ScanButton: UIView {
    
    private let mReceive = Button().apply({
        $0.setTitleColor(Style.Colors.white, for: .normal)
        $0.backgroundColor = Style.Colors.blue
        $0.setTitle("receive".loc, for: .normal)
    })
    
    private let mScan = Button().apply({
        $0.setTitleColor(Style.Colors.white, for: .normal)
        $0.backgroundColor = Style.Colors.blue
        $0.setTitle("scan".loc, for: .normal)
    })

    var onScan: ()->Void = {}
    var onReceive: ()->Void = {}
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(mScan)
        addSubview(mReceive)
        mReceive.tap({ [weak self] in
            self?.onReceive()
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
        let w = floor((width - 40.scaled)/2.0)
        mReceive.frame = CGRect(x: 0, y: 0, width: w, height: height)
        mScan.frame = CGRect(x: width - w, y: 0, width: w, height: height)
    }
    
}
