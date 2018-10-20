//
//  AuthVC.swift
//  MultiMask
//
//  Created by Kirill Kozhuhar on 01/08/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import UIKit

class AuthVC : UIViewController {
    
    private lazy var mNewOne: Button = {
        let tmp = Button()
        tmp.backgroundColor = 0x1888FE.color
        tmp.setTitle("new_wallet".loc, for: UIControlState.normal)
        return tmp
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(mNewOne)
        mNewOne.click = { [weak self] in
            self?.navigationController?.pushViewController(NewCodeVC(purpose: .createWallet), animated: true)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        mNewOne.frame = CGRect(x: floor((view.width - 315.scaled)/2.0), y: floor((view.height - 60.scaled)/2.0), width: 315.scaled, height: 60.scaled)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
}
