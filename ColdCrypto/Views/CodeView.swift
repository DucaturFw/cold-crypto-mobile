//
//  CodeView.swift
//  MultiMask
//
//  Created by Kirill Kozhuhar on 02/08/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import UIKit

class CodeView : UIView {
    
    private lazy var mDots: [UIView] = {
        var tmp: [UIView] = []
        for i in 0...3 {
            let dot = UIView(frame: CGRect(x: 0, y: 0, width: 12.scaled, height: 12.scaled))
            dot.layer.borderWidth  = 1.0
            dot.layer.borderColor  = 0xC7CCD7.color.cgColor
            dot.layer.cornerRadius = dot.width/2.0
            tmp.append(dot)
        }
        return tmp
    }()
    
    private var fill: Int = 0 {
        didSet {
            fill = max(min(fill, mDots.count), 0)
            for (index, dot) in mDots.enumerated() {
                if index < fill {
                    dot.backgroundColor = 0x1888FE.color
                    dot.layer.borderWidth = 0.0
                } else {
                    dot.backgroundColor = .clear
                    dot.layer.borderWidth = 1.0
                }
            }
        }
    }
        
    private var mValue: String = ""
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        mDots.forEach({
            addSubview($0)
        })
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let w = CGFloat(mDots.count-1) * 32.scaled
        var x = (width - w)/2.0
        mDots.forEach({
            $0.center = CGPoint(x: x, y: height/2.0)
            x += 32.scaled
        })
    }
    
    func append(key: Int, onDone: (String)->Void) {
        mValue = "\(mValue)\(key)"
        fill += 1
        if fill == mDots.count {
            onDone(mValue)
        }
    }
    
    func clear() {
        mValue = ""
        fill = 0
    }
    
    func incorrect() {
        mValue = ""
        fill = 0
        shake()
    }
 
    func fakeFill() {
        fill = mDots.count
    }
    
}
