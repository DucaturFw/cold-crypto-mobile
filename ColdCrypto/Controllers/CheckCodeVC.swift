//
//  CreateCodeVC.swift
//  MultiMask
//
//  Created by Kirill Kozhuhar on 04/08/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import UIKit

class CheckCodeVC: CodeVC {
    
    private let mPasscode: String
    private let onSuccess: (CheckCodeVC)->Void

    private let mCanSkip: Bool
    
    override var dragable: Bool {
        return mCanSkip
    }
    
    private var mAuthAtStart = false

    convenience init(passcode: String, canSkip: Bool = true, authAtStart: Bool, onSuccess block: @escaping (CheckCodeVC)->Void) {
        self.init(passcode: passcode, canSkip: canSkip, onSuccess: block)
        mAuthAtStart = authAtStart
    }
    
    init(passcode: String, canSkip: Bool = true, onSuccess block: @escaping (CheckCodeVC)->Void) {
        mPasscode = passcode
        onSuccess = block
        mCanSkip  = canSkip
        super.init(nibName: nil, bundle: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(startBioAuth), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    var hintText: String? {
        get {
            return hint.text
        }
        set {
            hint.text = newValue
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        hint.text = "enter_hint".loc
        name.text = "enter_access_code".loc
        name.sizeToFit()
    }
    
    @objc func startBioAuth() {
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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if mAuthAtStart {
            mAuthAtStart = false
            startBioAuth()
        }
    }
    
}
