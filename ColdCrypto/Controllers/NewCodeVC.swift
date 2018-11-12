//
//  NewCodeVC.swift
//  MultiMask
//
//  Created by Kirill Kozhuhar on 04/08/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import UIKit

class NewCodeVC : CodeVC {

    private var mFirstCode: String? = nil

    var onCode: (String)->Void = { _ in }

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
        if let passcode = mFirstCode {
            onCode(passcode)
        }
    }

}
