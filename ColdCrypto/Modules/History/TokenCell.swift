//
//  TokenCell.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 03/03/2019.
//  Copyright © 2019 Kirill Kozhuhar. All rights reserved.
//

import Foundation

class TokenCell: UICollectionViewCell {

    @IBOutlet
    private var mBG: UIView?
    
    @IBOutlet
    private var mTint: UIImageView?
    var tint: UIImage? {
        get {
            return mTint?.image
        }
        set {
            mTint?.image = newValue
        }
    }
    
    @IBOutlet
    private var mText: UILabel?
    var value: String? {
        get {
            return mText?.text
        }
        set {
            mText?.text = newValue
        }
    }
    
    @IBOutlet
    private var mUnits: UILabel?
    var units: String? {
        get {
            return mUnits?.text
        }
        set {
            mUnits?.text = newValue
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        mBG.map({
            $0.layer.cornerRadius = $0.height/2.0
        })
    }
    
    var onTapped: ()->Void = {}
    
    override func awakeFromNib() {
        super.awakeFromNib()
        tap({ [weak self] in
            self?.onTapped()
        })
    }
    
}
