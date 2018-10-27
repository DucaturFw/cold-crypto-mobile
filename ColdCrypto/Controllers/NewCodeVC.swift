//
//  NewCodeVC.swift
//  MultiMask
//
//  Created by Kirill Kozhuhar on 04/08/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import UIKit

class NewCodeVC : CodeVC {
    
    enum Purpose {
        case createWallet, importWallet
    }

    private var mFirstCode: String? = nil
    private let mPurpose: Purpose
    
    init(purpose: Purpose) {
        mPurpose = purpose
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
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
            hint.text = "cretae_rpt".loc
            mFirstCode = code
            self.code.clear()
        }
    }
    
    override func moveNext() {
        if mPurpose == .createWallet {
            createProfile(name: "Test", segwit: false)
        } else {
//            DispatchQueue.main.async {
//                self.navigationController?.pushViewController(ImportVC(backStyle: .toRoot, hintStyle: .newImport), animated: true)
//            }
        }
    }
    
    private func createProfile(name: String, segwit: Bool) {
        if let p = Profile.new(name: name, segwit: segwit) {
            Settings.profile = p
            navigationController?.setViewControllers([ProfileVC(profile: p, params: AppDelegate.params)], animated: true)
        }
    }
    
}
