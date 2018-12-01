//
//  BackupVC.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 11/11/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import UIKit

class BackupVC: PopupVC {
    
    private var mWords = [UIView]()
    
    private let mSeed: String
    
    private let mBox = UIView().apply({
        $0.backgroundColor     = Style.Colors.white
        $0.layer.cornerRadius  = 6.0
        $0.layer.shadowColor   = UIColor.black.cgColor
        $0.layer.shadowOffset  = CGSize(width: 0, height: 0)
        $0.layer.shadowOpacity = 0.4
        $0.layer.shadowRadius  = 6.0
    })
    
    private let mCaption = UILabel.new(font: UIFont.hnRegular(15), text: "rec_phrsae".loc, lines: 1, color: .black, alignment: .left)
    private let mHint = UILabel.new(font: UIFont.hnRegular(15), text: "rec_hint".loc, lines: 0, color: Style.Colors.black.alpha(0.7), alignment: .left)
    
    private var mTopGap: CGFloat = 80
    override var topGap: CGFloat {
        return view.height - mTopGap
    }
    
    private lazy var mDone = Button().apply({ [weak self] in
        $0.backgroundColor = 0x1888FE.color
        $0.setTitle("done".loc, for: .normal)
        $0.click = { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }
    })
    
    init(seed: String) {
        mSeed = seed
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        content.addSubview(mBox)
        content.addSubview(mCaption)
        content.addSubview(mHint)
        content.addSubview(mDone)
        mSeed.split(separator: " ").enumerated().forEach({
            let v = SeedWord(index: $0.offset+1, word: String($0.element))
            mBox.addSubview(v)
            mWords.append(v)
        })
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let g = CGFloat(20.0)
        let c = CGFloat(view.width - 40)
        let w = CGFloat((c - g*3)/2)
        let s = mWords.count == 24 ? 12 : 6
        
        var y = CGFloat(20.0)
        var x = g
        var h = CGFloat(0.0)
        
        mWords.enumerated().forEach({
            $0.element.frame = CGRect(x: x, y: y, width: w, height: $0.element.height)
            h = max(h, $0.element.maxY)
            if ($0.offset+1) % s == 0 && $0.offset > 0 {
                x = x + w + CGFloat(g)
                y = CGFloat(20.0)
            } else {
                y = $0.element.maxY + CGFloat(5.0)
            }
        })
        
        mCaption.frame = CGRect(x: (view.width - c)/2.0, y: 20, width: c, height: mCaption.height)
        mBox.frame = CGRect(x: mCaption.minX, y: mCaption.maxY + 10, width: c, height: h + 20.0)
        let th = mHint.text?.heightFor(width: mBox.width, font: mHint.font) ?? 0
        mHint.frame = CGRect(x: mCaption.minX, y: mBox.maxY + 10, width: mBox.width, height: th)
        mDone.frame = CGRect(x: mHint.minX, y: mHint.maxY + 20, width: mHint.width, height: 45)
        mTopGap = mDone.maxY + 20 + AppDelegate.bottomGap
    }

}
