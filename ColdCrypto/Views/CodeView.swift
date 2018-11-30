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
            let dot = UIView(frame: CGRect(x: 0, y: 0, width: 20.scaled, height: 20.scaled))
            dot.layer.borderWidth  = 4.scaled
            dot.layer.borderColor  = Style.Colors.blue.cgColor
            dot.layer.cornerRadius = dot.width/2.0
            tmp.append(dot)
        }
        return tmp
    }()
    
    private var fill: Int = 0 {
        didSet {
            fill = max(min(fill, mDots.count), 0)
            for (index, dot) in mDots.enumerated() {
                dot.backgroundColor = index < fill ? Style.Colors.blue : .clear
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
        let w = CGFloat(mDots.count-1) * 46.scaled
        var x = (width - w)/2.0
        mDots.forEach({
            $0.center = CGPoint(x: x, y: height/2.0)
            x += 46.scaled
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
