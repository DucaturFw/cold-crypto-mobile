//
//  BackupView.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 02/12/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import UIKit

class BackupView: UIView, IAlertView {
    
    private var mWords = [UIView]()
    
    private let mBox = UIView().apply({
        $0.backgroundColor     = Style.Colors.white
        $0.layer.cornerRadius  = 6.0
        $0.layer.shadowColor   = UIColor.black.cgColor
        $0.layer.shadowOffset  = CGSize(width: 0, height: 0)
        $0.layer.shadowOpacity = 0.4
        $0.layer.shadowRadius  = 6.0
    })
    
    private let mCaption = UILabel.new(font: UIFont.medium(25), text: "rec_phrsae".loc, lines: 1, color: .black, alignment: .left)
    private let mHint = UILabel.new(font: UIFont.regular(15), text: "rec_hint".loc, lines: 0, color: Style.Colors.black.alpha(0.7), alignment: .left)
    
    init(seed: String) {
        super.init(frame: .zero)
        addSubview(mBox)
        addSubview(mCaption)
        addSubview(mHint)
        seed.split(separator: " ").enumerated().forEach({
            let v = SeedWord(index: $0.offset+1, word: String($0.element))
            mBox.addSubview(v)
            mWords.append(v)
        })
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    func layout(width: CGFloat, origin o: CGPoint) {
        let s = mWords.count == 24 ? 12 : 6
        var y = CGFloat(20.0)
        var x = CGFloat(20)
        var h = CGFloat(0.0)
        
        mCaption.origin = CGPoint(x: (width - mCaption.width)/2.0, y: 0)
        mWords.enumerated().forEach({
            $0.element.frame = CGRect(x: x, y: y, width: width/2, height: $0.element.height)
            h = max(h, $0.element.maxY)
            if ($0.offset+1) % s == 0 && $0.offset > 0 {
                x = x + width/2
                y = CGFloat(20.0)
            } else {
                y = $0.element.maxY + CGFloat(5.0)
            }
        })
        mBox.frame = CGRect(x: 0, y: mCaption.maxY + 40.scaled, width: width, height: h + 20.0)
        let th = mHint.text?.heightFor(width: mBox.width, font: mHint.font) ?? 0
        mHint.frame = CGRect(x: 0, y: mBox.maxY + 40.scaled, width: mBox.width, height: th)
        frame = CGRect(x: o.x, y: o.y, width: width, height: mHint.maxY)
    }
    
}
