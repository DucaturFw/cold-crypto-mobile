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
    private var mTopGap = CGFloat(80)
    override var topGap: CGFloat {
        return mTopGap
    }
    
    private let mBlock: (String?)->Void
    
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
    
    private var mViews: [UIView] = []

    private let mInvalid = UILabel.new(font: UIFont.hnMedium(20.scaled), text: "invalid".loc, lines: 0, color: .black, alignment: .center)
    
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

        print("\(mContract.isValid())")
        
        if mContract.isValid(),
            let call = mContract.abi?.method,
            let data = mContract.tx?.data,
            let pack = ETHabi.convert(call: call, data: data),
            let cont = ContractImpl.deserialize(from: pack) {
            mInvalid.isVisible = false
            let v = ContractView(contract: cont)
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
    
    override func viewDidLayoutSubviews() {
        var t = CGFloat(0)
        mViews.forEach({
            $0.frame = CGRect(x: 0, y: t, width: view.width, height: $0.height)
            $0.setNeedsLayout()
            $0.layoutIfNeeded()
            t = ceil($0.maxY)
        })

        if mInvalid.isVisible {
            mInvalid.origin = CGPoint(x: (view.width - mInvalid.width)/2.0, y: t + 30.scaled)
            t = ceil(mInvalid.maxY + 30.scaled)
        }

        let w = (view.width - 76.scaled)/2.0
        if mConfirm.isVisible {
            mDecline.frame = CGRect(x: 30.scaled, y: t, width: w, height: 64.scaled)
            mConfirm.frame = CGRect(x: mDecline.maxX + 16.scaled, y: mDecline.minY, width: mDecline.width, height: mDecline.height)
        } else {
            mDecline.frame = CGRect(x: 30.scaled, y: t, width: view.width - 60.scaled, height: 64.scaled)
        }
        t = ceil(mDecline.maxY + 34.scaled)

        let max = view.height - view.bottomGap - mMinTop
        if t > max {
            mScroll.frame = CGRect(x: 0, y: 0, width: view.width, height: max)
            mScroll.contentSize.height = t
            mTopGap = mMinTop
        } else {
            mScroll.frame = CGRect(x: 0, y: 0, width: view.width, height: t)
            mScroll.contentSize.height = 0
            mTopGap = view.height - mScroll.height - view.bottomGap
        }
        super.viewDidLayoutSubviews()
    }
    
    private func confirm() {
        guard let to = mContract.tx else { return }
        guard let wallet = mContract.wallet else { return }
        present(CheckCodeVC(passcode: mPasscode, authAtStart: true, onSuccess: { [weak self] vc in
            vc.dismiss(animated: true, completion: { [weak self] in
                if let b = self?.mBlock {
                    self?.mWallet.sign(transaction: to, wallet: wallet, completion: b)
                }                
            })
        }).apply({
            $0.hintText = "confirm_hint".loc
        }), animated: true, completion: nil)
    }
    
}
