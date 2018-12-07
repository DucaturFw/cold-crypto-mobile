//
//  NewTransaction.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 06/12/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import Foundation

class NewTransaction: UIView, IAlertView, UITextFieldDelegate {
    
    private let mName   = UILabel.new(font: UIFont.medium(25.scaled), text: "new_trans".loc, lines: 1, color: Style.Colors.black, alignment: .center)
    private let mSendTo = UILabel.new(font: UIFont.medium(15.scaled), text: "send_to".loc, lines: 1, color: Style.Colors.darkGrey, alignment: .center)
    private let mAmount = UILabel.new(font: UIFont.medium(15.scaled), text: "amount".loc, lines: 1, color: Style.Colors.darkGrey, alignment: .center)
    private let mFeeCap = UILabel.new(font: UIFont.medium(15.scaled), text: "fee".loc, lines: 1, color: Style.Colors.darkGrey, alignment: .center)
    
    private let mScan = ScanButton(frame: CGRect(origin: .zero, size: CGSize(width: Style.Dims.middle, height: Style.Dims.middle)))
    
    private lazy var mField = Field().apply({ [weak self] in
        $0.delegate = self
    })
    
    private lazy var mAmountField = Field().apply({ [weak self] in
        $0.delegate = self
    })
    
    private lazy var mFee = Field().apply({ [weak self] in
        $0.delegate = self
    })
    
    private let mCancel = Button().apply({
        $0.setTitleColor(Style.Colors.white, for: .normal)
        $0.backgroundColor = Style.Colors.darkGrey
        $0.setTitle("cancel".loc, for: .normal)
    })
    
    private let mSend = Button().apply({
        $0.setTitleColor(Style.Colors.white, for: .normal)
        $0.backgroundColor = Style.Colors.blue
        $0.setTitle("send".loc, for: .normal)
    })
    
    private weak var mParent: AlertVC?
    
    init(parent: AlertVC) {
        mParent = parent
        super.init(frame: .zero)
        addSubview(mName)
        addSubview(mSendTo)
        addSubview(mScan)
        addSubview(mField)
        addSubview(mAmount)
        addSubview(mAmountField)
        addSubview(mFeeCap)
        addSubview(mFee)
        addSubview(mCancel)
        addSubview(mSend)
        mCancel.click = { [weak self] in
            self?.mParent?.dismiss(animated: true, completion: nil)
        }
        mSend.click = { [weak self] in
            self?.mParent?.dismiss(animated: true, completion: nil)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    func layout(width: CGFloat, origin: CGPoint) {
        mName.origin = CGPoint(x: (width - mName.width)/2.0, y: 0)
        mSendTo.origin = CGPoint(x: (width - mSendTo.width)/2.0, y: mName.maxY + Style.Dims.middle)
        mField.frame = CGRect(x: 0, y: mSendTo.maxY + Style.Dims.small,
                              width: width - 10.scaled - Style.Dims.small, height: Style.Dims.middle)
        mScan.origin = CGPoint(x: mField.maxX + 10.scaled, y: mField.minY)
        mAmount.origin = CGPoint(x: (width - mAmount.width)/2.0, y: mField.maxY + Style.Dims.middle)
        mAmountField.frame = CGRect(x: 0, y: mAmount.maxY + Style.Dims.small,
                                    width: width - 110.scaled, height: Style.Dims.middle)
        mFeeCap.origin = CGPoint(x: (width - mFeeCap.width)/2.0, y: mAmountField.maxY + Style.Dims.middle)
        mFee.frame = CGRect(x: 0, y: mFeeCap.maxY + Style.Dims.small, width: width, height: Style.Dims.middle)
        
        let w = (width - Style.Dims.middle)/2.0
        mCancel.frame = CGRect(x: 0, y: mFee.maxY + Style.Dims.middle, width: w, height: Style.Dims.middle)
        mSend.frame = CGRect(x: mCancel.maxX + Style.Dims.middle, y: mCancel.minY, width: mCancel.width, height: mCancel.height)
        
        frame = CGRect(origin: origin, size: CGSize(width: width, height: mSend.maxY + Style.Dims.middle))
    }
    
}
