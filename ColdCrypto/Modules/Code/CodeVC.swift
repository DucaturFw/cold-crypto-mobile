//
//  CodeVC.swift
//  MultiMask
//
//  Created by Kirill Kozhuhar on 02/08/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import UIKit

class CodeVC : UIViewController {
    
    private let mHint = UILabel.new(font: .medium(15.scaled),
                                    text: "cretae_hint".loc,
                                    lines: 0,
                                    color: Style.Colors.black.alpha(0.5),
                                    alignment: .center)
    var hint: UILabel {
        return mHint
    }
    
    private let mContent = UIView()
    
    private let mAuth = BioAuth()
    var auth: BioAuth {
        return mAuth
    }
    
    var inNC: UINavigationController {
        return NavigatorVC(rootViewController: self)
    }
    
    private let mKeys = NumberPad()
    
    private let mCode = CodeView()
    var code: CodeView {
        return mCode
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Style.Colors.white
        mContent.addSubview(mHint)
        mContent.addSubview(mKeys)
        mContent.addSubview(mCode)
        view.addSubview(mContent)
        mKeys.onClick = { [weak self] key in
            self?.append(key: key)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        mHint.origin = CGPoint(x: (view.width - mHint.width)/2.0, y: 45.scaled)
        mCode.origin = CGPoint(x: (view.width - mCode.width)/2.0, y: 108.scaled)
        mKeys.origin = CGPoint(x: (view.width - mKeys.width)/2.0, y: 146.scaled)
        mContent.frame = CGRect(x: 0, y: (view.height - mKeys.maxY)/2.0, width: view.width, height: mKeys.maxY)
    }
    
    internal func authComplete() {
        let type = mAuth.authType
        if Settings.useBio == nil && type != .none {
            AlertVC((type == .face ? "ask_use_face" : "ask_use_touch").loc, draggable: false)
                .put(negative: "no".loc, do: { [weak self] a in
                    Settings.useBio = false
                    self?.moveNext()
                })
                .put("yes".loc, do: { [weak self] a in
                    Settings.useBio = true
                    self?.moveNext()
                }).show()
        } else {
            moveNext()
        }
    }
    
    private func append(key: Int) {
        mCode.append(key: key, onDone: { [weak self] (code) in
            self?.onComplete(code: code)
        })
    }
    
    func moveNext() {}
    
    func onComplete(code: String) {}
    
}
