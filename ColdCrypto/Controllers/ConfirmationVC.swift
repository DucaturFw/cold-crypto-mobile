//
//  ConfirmationVC.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 24/10/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import UIKit

class ConfirmationVC: UIViewController {
    
    private let mLogo = UIImageView(image: UIImage(named: "topWhite"))
    
    private let mBG = UIImageView(image: UIImage(named: "bg")).apply({
        $0.contentMode = .scaleAspectFill
    })
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private let mBox = UIView().apply({
        $0.backgroundColor = UIColor.white
    })
    
    private let mDecline = Button().apply({
        $0.setTitleColor(UIColor.white, for: .normal)
        $0.backgroundColor = 0xE26E7C.color
        $0.setTitle("decline".loc, for: UIControlState.normal)
    })
    
    private let mConfirm = Button().apply({
        $0.setTitleColor(UIColor.white, for: .normal)
        $0.backgroundColor = 0x007AFF.color
        $0.setTitle("confirm".loc, for: UIControlState.normal)
    })
    
    private let mName = UILabel.new(font: UIFont.hnBold(30.scaled), text: "verify".loc, lines: 0, color: 0x007AFF.color, alignment: .left)
    
    private let mOnConfirm: ()->Void
    
    init(to: ApiDestination, onConfirm: @escaping ()->Void) {
        mOnConfirm = onConfirm
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(mBG)
        view.addSubview(mLogo)
        view.addSubview(mBox)
        mBox.addSubview(mName)
        mBox.addSubview(mDecline)
        mBox.addSubview(mConfirm)
        
        mDecline.click = { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }
        mConfirm.click = { [weak self] in
            self?.mOnConfirm()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        mBox.transform = CGAffineTransform(translationX: 0, y: view.height)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        mBG.frame = view.bounds
        let t = UIApplication.shared.statusBarFrame.maxY
        let b = 58.scaled
        mLogo.origin = CGPoint(x: (view.width - mLogo.width)/2.0, y: t + (b - mLogo.height)/2.0)
        
        let tmp = mBox.transform
        mBox.transform = .identity
        mBox.frame = CGRect(x: 0, y: t + b, width: view.width, height: view.height - t - b)
        mBox.round(corners: [.topLeft, .topRight], radius: 10.scaled)
        mBox.transform = tmp
        
        mName.origin = CGPoint(x: 18.scaled, y: 48.scaled)
        
        let w = (view.width - 76.scaled)/2.0
        mDecline.frame = CGRect(x: 30.scaled, y: mBox.height - 100.scaled, width: w, height: 64.scaled)
        mConfirm.frame = CGRect(x: mDecline.maxX + 16.scaled, y: mDecline.minY, width: mDecline.width, height: mDecline.height)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.35, animations: {
            self.mBox.transform = .identity
        })
    }
    
}
