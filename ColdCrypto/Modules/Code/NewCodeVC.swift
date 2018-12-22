//
//  NewCodeVC.swift
//  MultiMask
//
//  Created by Kirill Kozhuhar on 04/08/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import UIKit

class NewCodeVC : CodeVC {
    
    private lazy var mBack = JTHamburgerButton().apply({
        $0.lineColor = Style.Colors.darkGrey
        $0.lineSpacing = 5.0
        $0.lineWidth = 24
        $0.lineHeight = 2
        $0.angle = CGFloat.pi/4.0
        $0.setCurrentModeWithAnimation(.arrow, duration: 0)
    }).tap({ [weak self] in
        if (self?.navigationController?.viewControllers.count ?? 0) > 1 {
            self?.navigationController?.popViewController(animated: true)
        } else {
            self?.navigationController?.dismiss(animated: true, completion: nil)
        }
    })

    private var mFirstCode: String? = nil

    var onCode: (String)->Void = { _ in }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: mBack)
        navigationItem.title = "create_code".loc
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func onComplete(code: String) {
        if let fcode = mFirstCode {
            if fcode == code {
                Settings.passcode = code
                authComplete()
            } else {
                self.code.incorrect()
            }
        } else {
            navigationItem.title = "cretae_rpt".loc
            mFirstCode = code
            self.code.clear()
        }
    }
    
    override func moveNext() {
        if let passcode = mFirstCode {
            onCode(passcode)
        }
    }

}
