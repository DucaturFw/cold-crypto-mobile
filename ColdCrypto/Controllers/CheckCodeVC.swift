//
//  CreateCodeVC.swift
//  MultiMask
//
//  Created by Kirill Kozhuhar on 04/08/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import UIKit

class CheckCodeVC: CodeVC {
    
    enum Style {
        case overlay, normal
    }
    
    private let mPasscode: String
    
    private let mBack = UIImageView().apply({
        $0.contentMode = .center
    })

    private let onSuccess: (CheckCodeVC)->Void
    
    private let mStyle: Style
    
    init(passcode: String, style: Style, onSuccess block: @escaping (CheckCodeVC)->Void) {
        mPasscode = passcode
        onSuccess = block
        mStyle = style
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        mBack.image = UIImage(named: navigationController != nil ? "back" : "hide")
        mBack.isVisible = isBeingPresented
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        hint.text = "enter_hint".loc
        name.text = "enter_access_code".loc
        name.sizeToFit()
        
        if mStyle == .normal {
            view.addSubview(mBack)
            mBack.tap({ [weak self] in
                if let nc = self?.navigationController {
                    nc.popViewController(animated: true)
                } else {
                    self?.dismiss(animated: true, completion: nil)
                }
            })
            
            startBioAuth()
        } else {
            view.backgroundColor = .clear
        }
    }
    
    func startBioAuth() {
        if auth.authType != .none && Settings.useBio == true {
            auth.tryToAuthWithBio { [weak self] (success) in
                if success, let s = self {
                    s.code.fakeFill()
                    s.moveNext()
                }
            }
        }
    }
    
    override func moveNext() {
        onSuccess(self)
    }
    
    override func onComplete(code: String) {
        view.isUserInteractionEnabled = false
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + DispatchTimeInterval.milliseconds(200), execute: {
            self.view.isUserInteractionEnabled = true
            if self.mPasscode != code {
                self.code.incorrect()
            } else {
                self.authComplete()
            }
        })
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        mBack.frame = CGRect(x: 4, y: floor(name.minY + (name.height - 40)/2.0), width: 40, height: 40)
    }
    
}
