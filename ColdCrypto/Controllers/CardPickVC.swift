//
//  CardPickVC.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 07/11/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import UIKit

class CardPickVC: PopupVC {
    
    private var mDrag = false
    override var dragable: Bool {
        return mDrag
    }
    
    private let mCaption = UILabel.new(font: UIFont.hnMedium(24.scaled), text: "select_wallet".loc, lines: 0, color: .black, alignment: .center)
    
    private let mDecline = Button().apply({
        $0.setTitleColor(UIColor.white, for: .normal)
        $0.backgroundColor = 0xE26E7C.color
        $0.setTitle("cancel".loc.uppercased(), for: UIControlState.normal)
    })
    
    private let mConfirm = Button().apply({
        $0.setTitleColor(UIColor.white, for: .normal)
        $0.backgroundColor = 0x007AFF.color
        $0.setTitle("use".loc.uppercased(), for: UIControlState.normal)
        $0.alpha = 0.0
    })
    
    private let mView = CardsList(frame: UIScreen.main.bounds).apply({
        $0.detailsForCard = false
    })
    
    private var mActive: IWallet?
    
    init(profile: Profile, blockchain: Blockchain, completion: @escaping (IWallet?)->Void) {
        super.init(nibName: nil, bundle: nil)
        mView.wallets  = profile.chains.first(where: { $0.id == blockchain })?.wallets ?? []
        mView.onActive = { [weak self] w in
            if let s = self {
                s.mConfirm.alpha = (w == nil ? 0.0 : 1.0)
                s.mConfirm.isUserInteractionEnabled = (w != nil)
                s.view.setNeedsLayout()
                s.view.layoutIfNeeded()
                s.mActive = w
            }
        }
        mConfirm.click = { [weak self] in
            completion(self?.mActive)
            self?.dismiss(animated: true, completion: nil)
        }
        if mView.wallets.count == 0 {
            mView.isUserInteractionEnabled = false
            mCaption.text = "no_wallets".loc
            mDrag = true
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        content.addSubview(mView)
        content.addSubview(mCaption)
        content.addSubview(mDecline)
        content.addSubview(mConfirm)
        mDecline.click = { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        mView.frame = content.bounds
        mView.bottom = view.bottomGap + 100.scaled
        
        let w1 = (view.width - 18)/2.0
        let w2 = mConfirm.alpha < 0.5 ? (view.width - 12) : w1
        mDecline.frame = CGRect(x: 6, y: content.height - mView.bottom + 18.scaled, width: w2, height: 64.scaled)
        mConfirm.frame = CGRect(x: view.width - w1 - 6, y: mDecline.minY, width: w1, height: mDecline.height)
        
        if mView.wallets.count > 0 {
            mCaption.frame = CGRect(x: 0, y: 6, width: view.width, height: mView.top)
        } else {
            mCaption.frame = CGRect(x: 0, y: 0, width: view.width, height: mDecline.minY)
        }
    }
    
}
