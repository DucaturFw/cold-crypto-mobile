//
//  DeleteView.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 04/12/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import UIKit

class DeleteView: UIView, IAlertView {
    
    private let mName = UILabel.new(font: .medium(12), text: "delete_sure".loc, lines: 0, color: Style.Colors.black.alpha(0.6), alignment: .center)
    private let mBody = UILabel.new(font: .regular(12), text: "delete_body".loc, lines: 0, color: Style.Colors.black.alpha(0.6), alignment: .center)

    convenience init(caption: String, body: String) {
        self.init(frame: .zero)
        mName.text = caption
        mBody.text = body
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(mName)
        addSubview(mBody)
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    func layout(width: CGFloat, origin: CGPoint) {
        let h1 = mName.text?.heightFor(width: width-20.scaled, font: mName.font) ?? 0
        mName.frame = CGRect(x: 10.scaled, y: 0, width: width-20.scaled, height: h1)
        
        let h2 = mBody.text?.heightFor(width: width-20.scaled, font: mBody.font) ?? 0
        mBody.frame = CGRect(x: 10.scaled, y: mName.maxY + mName.font.lineHeight, width: width-20.scaled, height: h2)
        frame = CGRect(origin: origin, size: CGSize(width: width, height: mBody.maxY + 10.scaled))
    }
    
}
