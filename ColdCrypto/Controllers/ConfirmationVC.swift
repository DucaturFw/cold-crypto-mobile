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
        $0.setTitleColor(Style.Colors.white, for: .normal)
        $0.backgroundColor = Style.Colors.red
        $0.setTitle("decline".loc, for: .normal)
    })
    
    private let mConfirm = Button().apply({
        $0.setTitleColor(Style.Colors.white, for: .normal)
        $0.backgroundColor = Style.Colors.blue
        $0.setTitle("confirm".loc, for: .normal)
    })
    
    private let mArrow = UIImageView(image: UIImage(named: "arrowDown"))
    
    private let mName = UILabel.new(font: UIFont.proMedium(25.scaled), text: "verify".loc, lines: 0, color: Style.Colors.black, alignment: .left)
    private let mOnConfirm: ()->Void
    private let mAddress: Checkbox
    private let mAmount: Checkbox
    
    init(to: String, amount: String, onConfirm: @escaping ()->Void) {
        mOnConfirm = onConfirm
        mAddress = Checkbox(name: "check_address".loc, value: to)
        mAmount = Checkbox(name: "check_amount".loc, value: amount)
        super.init(nibName: nil, bundle: nil)
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
        content.addSubview(mArrow)
        
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
        mConfirm.isActive = false
    }
    
    private func checkConfirm() {
        mConfirm.isActive = mAmount.isChecked && mAddress.isChecked
    }
    
    override func doLayout() -> CGFloat {
        mArrow.origin  = CGPoint(x: (view.width - mArrow.width)/2.0, y: 40.scaled)
        mName.origin   = CGPoint(x: (view.width - mName.width)/2.0, y: mArrow.maxY + 40.scaled)
        mAddress.frame = CGRect(x: 40.scaled, y: mName.maxY + 40.scaled, width: view.width - 80.scaled, height: 80.scaled)
        mAmount.frame  = CGRect(x: 40.scaled, y: mAddress.maxY + 50.scaled, width: mAddress.width, height: 80.scaled)
        
        let p = 40.scaled
        let w = (view.width - p * 3.0)/2.0

        mDecline.frame = CGRect(x: p, y: mAmount.maxY + p, width: w, height: Style.Dims.buttonMiddle)
        mConfirm.frame = CGRect(x: mDecline.maxX + p, y: mDecline.minY, width: mDecline.width, height: mDecline.height)
        
        return mDecline.maxY + p
    }
    
}
