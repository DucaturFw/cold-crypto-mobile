//
//  ConfirmationVC.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 24/10/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import UIKit

class ConfirmationVC: PopupVC {
    
    private let mDecline = Button().apply({
        $0.setTitleColor(UIColor.white, for: .normal)
        $0.backgroundColor = 0xE26E7C.color
        $0.setTitle("decline".loc, for: .normal)
    })
    
    private let mConfirm = Button().apply({
        $0.setTitleColor(UIColor.white, for: .normal)
        $0.backgroundColor = 0x007AFF.color
        $0.setTitle("confirm".loc, for: .normal)
    })
    
    private let mName = UILabel.new(font: UIFont.hnBold(30.scaled), text: "verify".loc, lines: 0, color: 0x007AFF.color, alignment: .left)
    private let mOnConfirm: ()->Void
    private let mAddress: Checkbox
    private let mAmount: Checkbox
    
    init(to: String, amount: String, onConfirm: @escaping ()->Void) {
        mOnConfirm = onConfirm
        mAddress = Checkbox(name: "check_address".loc, value: to)
        mAmount = Checkbox(name: "check_amount".loc, value: amount)
        super.init(nibName: nil, bundle: nil)
    }
    
    private var isConfirmEnabled: Bool = false {
        didSet {
            mConfirm.isEnabled = isConfirmEnabled
            mConfirm.backgroundColor = isConfirmEnabled ? 0x007AFF.color : 0xDCDCDC.color
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        content.addSubview(mName)
        content.addSubview(mDecline)
        content.addSubview(mConfirm)
        content.addSubview(mAddress)
        content.addSubview(mAmount)
        
        mAmount.onChecked = { [weak self] _ in
            self?.checkConfirm()
        }
        mAddress.onChecked = { [weak self] _ in
            self?.checkConfirm()
        }
        mDecline.click = { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }
        mConfirm.click = { [weak self] in
            self?.mOnConfirm()
        }
        
        isConfirmEnabled = false
    }
    
    private func checkConfirm() {
        isConfirmEnabled = mAmount.isChecked && mAddress.isChecked
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        mName.origin   = CGPoint(x: 18.scaled, y: 48.scaled)
        mAddress.frame = CGRect(x: 25.scaled, y: mName.maxY + 45.scaled, width: content.width - 60.scaled, height: 0)
        mAmount.frame  = CGRect(x: 25.scaled, y: mAddress.maxY + 17.scaled, width: mAddress.width, height: 0)
        
        let w = (content.width - 76.scaled)/2.0
        mDecline.frame = CGRect(x: 30.scaled, y: content.height - view.bottomGap - 100.scaled, width: w, height: 64.scaled)
        mConfirm.frame = CGRect(x: mDecline.maxX + 16.scaled, y: mDecline.minY, width: mDecline.width, height: mDecline.height)
    }
    
}
