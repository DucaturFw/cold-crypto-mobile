//
//  AuthVC.swift
//  MultiMask
//
//  Created by Kirill Kozhuhar on 01/08/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import UIKit

class AuthVC : UIViewController {
    
    private let mLogo = UIImageView(image: UIImage(named: "logo"))
    
    private let mNewOne = Button().apply({
        $0.setTitleColor(0x007AFF.color, for: .normal)
        $0.backgroundColor = UIColor.white
        $0.setTitle("new_wallet".loc, for: .normal)
        $0.layer.shadowColor   = 0x000000.color.cgColor
        $0.layer.shadowOffset  = CGSize(width: 0, height: 2)
        $0.layer.shadowOpacity = 0.22
        $0.layer.shadowRadius  = 17.scaled
    })
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if let p = presentedViewController, !p.isBeingDismissed {
            return p.preferredStatusBarStyle
        }
        return .lightContent
    }
    
    private let mBG = UIImageView(image: UIImage(named: "bg")).apply({
        $0.contentMode = .scaleAspectFill
    })
    
    private let mTop = UIImageView(image: UIImage(named: "logoTop"))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(mBG)
        view.addSubview(mNewOne)
        view.addSubview(mLogo)
        view.addSubview(mTop)
        mNewOne.click = { [weak self] in
            self?.newWallet()
        }
        mNewOne.transform = CGAffineTransform(translationX: 0, y: AppDelegate.bottomGap + 135.scaled)
    }
    
    private func newWallet() {
        let vc = NewCodeVC()
        vc.onCode = { [weak self, weak vc] passcode in
            vc?.dismiss(animated: true, completion: {
                self?.navigationController?.setViewControllers([PasswordVC(passcode: passcode)], animated: true)
            })
        }
        present(vc, animated: true, completion: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        mBG.frame = view.bounds
        mLogo.center = CGPoint(x: view.width/2.0, y: view.height/2.0)
        mTop.origin = CGPoint(x: floor((view.width - mTop.width)/2.0), y: floor(29.scaled + UIApplication.shared.statusBarFrame.maxY))
        
        let t = mNewOne.transform
        mNewOne.transform = .identity
        mNewOne.frame = CGRect(x: floor((view.width - 307.scaled)/2.0),
                               y: floor(view.height - view.bottomGap - 135.scaled),
                               width: 307.scaled,
                               height: 57.scaled)
        mNewOne.transform = t
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(250), execute: {
            self.onStart()
        })
    }
    
    private func onStart() {
        if let code = Settings.passcode, let p = Settings.profile {
            present(CheckCodeVC(passcode: code, canSkip: false, onSuccess: { [weak self] vc in
                vc.dismiss(animated: true, completion: nil)
                self?.navigationController?.setViewControllers([ProfileVC(profile: p,
                                                                          passcode: code,
                                                                          params: AppDelegate.params)], animated: true)
            }), animated: true, completion: nil)
            setNeedsStatusBarAppearanceUpdate()
        } else {
            UIView.animate(withDuration: 0.6, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: [], animations: {
                self.mNewOne.transform = .identity
            }, completion: nil)
        }
    }

}
