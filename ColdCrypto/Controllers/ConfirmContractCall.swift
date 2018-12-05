//
//  ConfirmContractCall.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 21/11/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import Foundation
import UIKit

class ConfirmContractCall: PopupVC {
    
    override var dragable: Bool {
        return false
    }

    private let mScroll = UIScrollView().apply({
        $0.clipsToBounds = false
    })
    
    private let mContract: ApiSignContractCall
    private let mPasscode: String
    private let mWallet: IWallet
    
    private let mMinTop = CGFloat(80)
    
    private let mBlock: (String?)->Void
    
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
    
    private var mViews: [UIView] = []

    private let mInvalid = UILabel.new(font: UIFont.medium(20.scaled), text: "invalid".loc, lines: 0, color: .black, alignment: .center)
    
    init(contract: ApiSignContractCall, wallet: IWallet, passcode: String, completion: @escaping (String?)->Void) {
        mContract = contract
        mPasscode = passcode
        mWallet = wallet
        mBlock  = completion
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        content.addSubview(mScroll)
        
        if let c = mWallet.parseContract(contract: mContract) {
            mInvalid.isVisible = false
            let v = ContractView(contract: c)
            mViews.append(v)
            mScroll.addSubview(v)
            mScroll.addSubview(mDecline)
            mScroll.addSubview(mConfirm)
        } else {
            mConfirm.isVisible = false
            mScroll.isScrollEnabled = false
            mScroll.addSubview(mDecline)
            mScroll.addSubview(mInvalid)
            mDecline.setTitle("close".loc, for: .normal)
        }
        mDecline.click = { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }
        mConfirm.click = { [weak self] in
            self?.confirm()
        }
    }
    
    override func doLayout() -> CGFloat {
        var t = CGFloat(0)
        mViews.forEach({
            $0.frame = CGRect(x: 0, y: t, width: width, height: $0.height)
            $0.setNeedsLayout()
            $0.layoutIfNeeded()
            t = ceil($0.maxY)
        })
        
        if mInvalid.isVisible {
            mInvalid.origin = CGPoint(x: (width - mInvalid.width)/2.0, y: t + 30.scaled)
            t = ceil(mInvalid.maxY + 30.scaled)
        }
        
        let w = (width - 76.scaled)/2.0
        if mConfirm.isVisible {
            mDecline.frame = CGRect(x: 30.scaled, y: t, width: w, height: Style.Dims.buttonMiddle)
            mConfirm.frame = CGRect(x: mDecline.maxX + 16.scaled, y: mDecline.minY, width: mDecline.width, height: mDecline.height)
        } else {
            mDecline.frame = CGRect(x: 30.scaled, y: t, width: width - 60.scaled, height: Style.Dims.buttonMiddle)
        }
        t = ceil(mDecline.maxY + 34.scaled)
        
        let max = view.height - AppDelegate.bottomGap - mMinTop
        if t > max {
            mScroll.frame = CGRect(x: 0, y: 0, width: width, height: max)
            mScroll.contentSize.height = t
        } else {
            mScroll.frame = CGRect(x: 0, y: 0, width: width, height: t)
            mScroll.contentSize.height = 0
        }
        return mScroll.maxY
    }
    
    private func confirm() {
        guard let to = mContract.tx else { return }
        guard let wallet = mContract.wallet else { return }
        present(CheckCodeVC(passcode: mPasscode, authAtStart: true, onSuccess: { [weak self] vc in
            vc.dismiss(animated: true, completion: { [weak self] in
                if let b = self?.mBlock, let w = self?.mWallet {
                    let hud = HUD.show()
                    DispatchQueue.main.async {
                        w.sign(transaction: to, wallet: wallet, completion: { tx in
                            hud?.hide(animated: true)
                            b(tx)
                        })
                    }
                }
            })
        }).apply({
            $0.hintText = "confirm_hint".loc
        }).inNC, animated: true, completion: nil)
    }
    
}
