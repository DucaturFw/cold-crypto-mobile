//
//  QRView.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 07/12/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import UIKit
import QRCode

class QRView: UIView, IAlertView {
    
    static let dim = CGFloat(300)
    
    private var mImage: UIImageView?
    
    private let mName = UILabel.new(font: UIFont.medium(25.scaled), lines: 0, color: Style.Colors.black, alignment: .center)
    
    var image: UIImage? {
        return mImage?.image
    }
    
    let value: String
    
    init(name: String?, value: String) {
        self.value = value
        super.init(frame: .zero)
        
        if var qr = QRCode(value) {
            qr.size = CGSize(width: QRView.dim, height: QRView.dim)
            let img = UIImageView(image: qr.image).apply({
                $0.contentMode = .scaleAspectFill
            })
            mImage = img
            addSubview(img)
        }
        
        if let n = name {
            mName.text = n
            addSubview(mName)
        } else {
            mName.isVisible = false
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    func layout(width: CGFloat, origin o: CGPoint) {
        var top = CGFloat(0)
        if mName.isVisible {
            let t = mName.text?.heightFor(width: width, font: mName.font) ?? 0.0
            mName.frame = CGRect(x: 0, y: 0, width: width, height: t)
            top = mName.maxY + Style.Dims.middle
        }
        if let v = mImage {
            v.frame = CGRect(x: 0.0, y: top, width: width, height: width)
            top = v.maxY
        }
        frame = CGRect(origin: o, size: CGSize(width: width, height: top))
    }
    
}
