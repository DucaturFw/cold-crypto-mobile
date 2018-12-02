//
//  AuthVC.swift
//  MultiMask
//
//  Created by Kirill Kozhuhar on 01/08/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import UIKit

class AuthVC : UIViewController {
    
    private let mNewOne = Button().apply({
        $0.backgroundColor = Style.Colors.blue
        $0.setTitle("new_wallet".loc, for: .normal)
    })
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if let p = presentedViewController, !p.isBeingDismissed {
            return p.preferredStatusBarStyle
        }
        return .lightContent
    }
    
    private let mBG = UIImageView(image: UIImage(named: "background")).apply({
        $0.contentMode = .scaleAspectFill
    })
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(mBG)
        view.addSubview(mNewOne)
        mNewOne.click = { [weak self] in
            self?.newWallet()
        }
        mNewOne.transform = CGAffineTransform(translationX: 0, y: AppDelegate.bottomGap + 135.scaled)
    }
    
    private func newWallet() {
        let vc = NewCodeVC()
        vc.onCode = { [weak self] passcode in
            if let p = Profile.new(name: "Cold", segwit: false) {
                Settings.profile = p
                let pvc = ProfileVC(profile: p, passcode: passcode, params: AppDelegate.params)
                self?.navigationController?.pushViewController(pvc, animated: true)
                self?.navigationController?.setViewControllers([pvc], animated: false)
            }
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        mBG.frame = view.bounds
        
        let t = mNewOne.transform
        mNewOne.transform = .identity
        mNewOne.frame = CGRect(x: floor((view.width - 307.scaled)/2.0),
                               y: floor(view.height - AppDelegate.bottomGap - 135.scaled),
                               width: 307.scaled,
                               height: Style.Dims.buttonLarge)
        mNewOne.transform = t
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let code = Settings.passcode, let p = Settings.profile {
            let nc = navigationController
            nc?.setViewControllers([CheckCodeVC(passcode: code, forceHide: true, authAtStart: true, onSuccess: { vc in
                let vc = ProfileVC(profile: p,
                                   passcode: code,
                                   params: AppDelegate.params)
                nc?.pushViewController(vc, animated: true)
                nc?.setViewControllers([vc], animated: false)
            })], animated: true)
        } else {
            UIView.animate(withDuration: 0.6, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: [], animations: {
                self.mNewOne.transform = .identity
            }, completion: nil)
        }
    }

}
