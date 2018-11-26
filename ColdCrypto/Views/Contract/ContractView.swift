//
//  ContractView.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 21/11/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import Foundation
import UIKit

class ContractView: UIView {
    
    private let mCaption = UILabel.new(font: UIFont.hnMedium(18.scaled), lines: 0, color: .black, alignment: .center)
    
    private let mList = UILabel().apply({
        $0.numberOfLines = 0
    })
    
    private let mContract: IContract
    
    init(contract: IContract) {
        mContract = contract
        super.init(frame: .zero)
        mCaption.text = contract.name
        addSubview(mCaption)
        addSubview(mList)
        
        let p = NSMutableParagraphStyle()
        p.headIndent = 20
        p.tabStops = [NSTextTab(textAlignment: .left, location: 20.0, options: [:])]
        p.defaultTabInterval = 20
        p.lineBreakMode = .byCharWrapping
        
        let text = contract.params
        if text.count > 0 {
            mList.attributedText = NSAttributedString(string: text, attributes: [.font: UIFont.hnRegular(18.scaled),
                                                                                 .foregroundColor: UIColor.black,
                                                                                 .paragraphStyle: p])
        } else {
            p.alignment = .center
            mList.attributedText = NSAttributedString(string: "\("no_params".loc)\n\n", attributes: [.font: UIFont.hnRegular(18.scaled),
                                                                                                     .foregroundColor: UIColor.black,
                                                                                                     .paragraphStyle: p])
        }
    }

    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        var t = CGFloat(0)
        mCaption.apply({
            let w = width - 60.scaled
            let h = $0.text?.heightFor(width: w, font: $0.font) ?? 0
            $0.frame = CGRect(x: 30.scaled, y: t + 30.scaled, width: w, height: h)
            t = ceil($0.maxY)
        })
        
        let size = mList.attributedText?.boundingRect(with: CGSize(width: width - 60.scaled, height: CGFloat.infinity),
                                                      options: [.usesLineFragmentOrigin, .usesFontLeading],
                                                      context: nil) ?? .zero
        mList.frame = CGRect(x: 30.scaled, y: ceil(t + 30.scaled), width: width - 60.scaled, height: ceil(size.height))
        frame.size.height = ceil(mList.maxY)
    }
    
}
