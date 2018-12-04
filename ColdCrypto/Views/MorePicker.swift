//
//  MorePicker.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 04/12/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import UIKit

class MorePicker: UIView, IAlertView {
    
    private let mReceive = Button().apply {
        $0.backgroundColor = Style.Colors.darkGrey
        $0.setTitle("receive".loc, for: .normal)
    }
    
    private let mBackup = Button().apply {
        $0.backgroundColor = Style.Colors.darkGrey
        $0.setTitle("backup".loc, for: .normal)
    }
    
    private let mDelete = Button().apply {
        $0.backgroundColor = Style.Colors.red
        $0.setTitle("delete".loc, for: .normal)
    }
    
    var onDelete: ()->Void = {}
    var onReceive: ()->Void = {}
    var onBackup: ()->Void = {}
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(mReceive)
        addSubview(mBackup)
        addSubview(mDelete)
        mReceive.click = { [weak self] in
            self?.onReceive()
        }
        mDelete.click = { [weak self] in
            self?.onDelete()
        }
        mBackup.click = { [weak self] in
            self?.onBackup()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    func layout(width: CGFloat, origin o: CGPoint) {
        mReceive.frame = CGRect(x: 0, y: 0, width: width, height: Style.Dims.buttonMiddle)
        mBackup.frame = mReceive.frame.offsetBy(dx: 0, dy: mReceive.height + 20.scaled)
        mDelete.frame = mBackup.frame.offsetBy(dx: 0, dy: mBackup.height + 20.scaled)
        
        frame = CGRect(x: o.x, y: o.y, width: width, height: mDelete.maxY)
    }
    
}
