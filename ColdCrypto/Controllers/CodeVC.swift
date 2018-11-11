//
//  CodeVC.swift
//  MultiMask
//
//  Created by Kirill Kozhuhar on 02/08/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import UIKit

class CodeVC : UIViewController {
        
    private let mName = UILabel.new(font: UIFont.sfProMedium(25.scaled), text: "create_code".loc, lines: 1, color: .black, alignment: .center)
    var name: UILabel {
        return mName
    }
    
    private let mHint = UILabel.new(font: UIFont.sfProMedium(14.scaled), text: "cretae_hint".loc, lines: 0, color: 0xC7CCD7.color, alignment: .center)
    var hint: UILabel {
        return mHint
    }
    
    private let mAuth = BioAuth()
    var auth: BioAuth {
        return mAuth
    }
    
    private let mKeys = NumberPad()
    
    private let mCode = CodeView()
    var code: CodeView {
        return mCode
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(mName)
        view.addSubview(mHint)
        view.addSubview(mKeys)
        view.addSubview(mCode)
        mKeys.onClick = { [weak self] key in
            self?.append(key: key)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let top = UIApplication.shared.statusBarFrame.maxY
        let space = view.height - top - view.bottomGap
        let y = top + (space - mKeys.height - 178)/2.0
        mName.origin = CGPoint(x: (view.width - mName.width)/2.0, y: y)
        mHint.origin = CGPoint(x: (view.width - mHint.width)/2.0, y: y + 55.scaled)
        mKeys.origin = CGPoint(x: (view.width - mKeys.width)/2.0, y: y + 178.scaled)
        mCode.origin = CGPoint(x: (view.width - mCode.width)/2.0, y: y + 122.scaled)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    internal func authComplete() {
        let type = mAuth.authType
        if Settings.useBio == nil && type != .none {
            Alert((type == .face ? "ask_use_face" : "ask_use_touch").loc)
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
