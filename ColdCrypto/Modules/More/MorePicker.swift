//
//  MorePicker.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 04/12/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import UIKit

class MorePicker: UIView, IAlertView {

    private let mSendToken = Button().apply {
        $0.backgroundColor = Style.Colors.darkGrey
        $0.setTitle("send.token".loc, for: .normal)
    }
    
    private let mSend = Button().apply {
        $0.backgroundColor = Style.Colors.darkGrey
        $0.setTitle("send".loc, for: .normal)
    }
    
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
    var onSend: ()->Void = {}
    var onSendToken: ()->Void = {}
    
    init(sendToken: Bool) {
        super.init(frame: .zero)
        addSubview(mSendToken)
        mSendToken.isVisible = sendToken
        mSendToken.click = { [weak self] in
            self?.onSendToken()
        }

        addSubview(mSend)
        mSend.click = { [weak self] in
            self?.onSend()
        }
        
        addSubview(mReceive)
        mReceive.click = { [weak self] in
            self?.onReceive()
        }
        
        addSubview(mBackup)
        mBackup.click = { [weak self] in
            self?.onBackup()
        }

        addSubview(mDelete)
        mDelete.click = { [weak self] in
            self?.onDelete()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    func layout(width: CGFloat, origin o: CGPoint) {
        var top = CGFloat(0)
        var max = CGFloat(0)
        [mSendToken, mSend, mReceive, mBackup, mDelete].forEach({
            if $0.isVisible {
                $0.frame = CGRect(x: 0, y: top, width: width, height: Style.Dims.middle)
                top += $0.height + 20.scaled
                max = $0.maxY
            }
        })
        frame = CGRect(x: o.x, y: o.y, width: width, height: max)
    }
    
}
