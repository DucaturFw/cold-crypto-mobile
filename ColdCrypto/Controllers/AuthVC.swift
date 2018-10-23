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
        $0.setTitle("new_wallet".loc, for: UIControlState.normal)
        $0.layer.shadowColor   = 0x000000.color.cgColor
        $0.layer.shadowOffset  = CGSize(width: 0, height: 2)
        $0.layer.shadowOpacity = 0.22
        $0.layer.shadowRadius  = 17.scaled
    })
    
    private let mRestore = UILabel.new(font: UIFont.hnMedium(18.scaled),
                                       text: "restore".loc,
                                       lines: 1,
                                       color: .white,
                                       alignment: .center)
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
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
        view.addSubview(mRestore)
        mNewOne.click = { [weak self] in
            self?.navigationController?.pushViewController(NewCodeVC(purpose: .createWallet), animated: true)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        mBG.frame = view.bounds
        mLogo.center = CGPoint(x: view.width/2.0, y: view.height/2.0)
        mNewOne.frame = CGRect(x: floor((view.width - 307.scaled)/2.0), y: floor(view.height - 57.scaled - 78.scaled), width: 307.scaled, height: 57.scaled)
        mTop.origin = CGPoint(x: floor((view.width - mTop.width)/2.0), y: floor(29.scaled))
        mRestore.center = CGPoint(x: view.width/2.0, y: view.height - 33.scaled)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
}
