//
//  RepeatPassVC.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 02/11/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import Foundation
import UIKit

class RepeatPassVC: UIViewController {
    
    private let mBG = UIImageView(image: UIImage(named: "mainBG")).apply({
        $0.contentMode = .scaleAspectFill
    })
    
    private lazy var mCancel = UILabel.new(font: UIFont.hnMedium(18.scaled),
                                           text: "back".loc,
                                           lines: 1,
                                           color: 0x007AFF.color,
                                           alignment: .center).apply({
                                            $0.frame = $0.frame.insetBy(dx: -2.0, dy: -2.0)
                                           }).tap({ [weak self] in
                                            self?.navigationController?.popViewController(animated: true)
                                           })
    
    private lazy var mIcon = UIImageView(image: UIImage(named: "back")).tap({ [weak self] in
        self?.navigationController?.popViewController(animated: true)
    })
    
    private lazy var mNext = UILabel.new(font: UIFont.hnMedium(18.scaled),
                                         text: "next".loc,
                                         lines: 1,
                                         color: 0x007AFF.color,
                                         alignment: .center).apply({
                                            $0.frame = $0.frame.insetBy(dx: -18.0, dy: -2.0)
                                         }).tap({ [weak self] in
                                            if let p = Profile.new(name: "Test", segwit: false), let pass = self?.mPasscode {
                                                Settings.profile = p
                                                self?.navigationController?.setViewControllers([ProfileVC(profile: p,
                                                                                                          passcode: pass,
                                                                                                          params: AppDelegate.params)],
                                                                                               animated: true)
                                            }
                                         })
    
    private let mCaption = UILabel.new(font: UIFont.hnBold(36.scaled), text: "type_pass".loc, lines: 0, color: 0x007AFF.color, alignment: .left)
    
    private let mHint = UILabel.new(font: UIFont.hnMedium(20.scaled), text: "rest_pass".loc, lines: 0, color: .black, alignment: .left)
    
    private let mField = UITextField().apply({
        $0.font = UIFont.hnRegular(20.scaled)
        $0.textColor = Style.Colors.white
        $0.attributedPlaceholder = NSAttributedString(string: "pass_placeholder".loc,
                                                      attributes: [.font : UIFont.hnRegular(20.scaled),
                                                                   .foregroundColor: Style.Colors.white.alpha(0.5)])
        $0.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 18.scaled, height: 0))
        $0.leftViewMode = .always
        $0.tintColor = Style.Colors.white
        $0.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 18.scaled, height: 0))
        $0.rightViewMode = .always
        $0.backgroundColor = 0x007AFF.color
        $0.layer.cornerRadius = 12.scaled
        $0.isSecureTextEntry = true
    })
    
    private let mBottom = UILabel.new(font: UIFont.hnRegular(18.scaled), text: "repeat_pass_bot".loc, lines: 0, color: 0x9B9B9B.color, alignment: .left)
    
    private let mPassword: String
    private let mPasscode: String
    
    init(password: String, passcode: String) {
        mPassword = password
        mPasscode = passcode
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(mBG)
        view.addSubview(mCaption)
        view.addSubview(mHint)
        view.addSubview(mField)
        view.addSubview(mBottom)
        view.addSubview(mCancel)
        view.addSubview(mNext)
        view.addSubview(mIcon)
        
        mField.addTarget(self, action: #selector(textChanged), for: .editingChanged)
        textChanged()
    }
    
    @objc private func textChanged() {
        if let p = mField.text, p.count > 0 && p == mPassword {
            mNext.isUserInteractionEnabled = true
            mNext.textColor = 0x007AFF.color
        } else {
            mNext.isUserInteractionEnabled = true
            mNext.textColor = 0xB7B7B7.color
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let t = UIApplication.shared.statusBarFrame.maxY + 44
        let x = 18.scaled
        
        mBG.frame = view.bounds
        mCaption.origin = CGPoint(x: x, y: t + 6.scaled)
        mIcon.origin = CGPoint(x: x, y: t - 22 - mIcon.height/2.0)
        mCancel.origin = CGPoint(x: mIcon.maxX + 6.scaled, y: t - 22 - mCancel.height/2.0)
        mNext.origin = CGPoint(x: view.width - mNext.width, y: mCancel.minY)
        
        let w = view.width - x * 2.0
        let h = mHint.text?.heightFor(width: w, font: mHint.font) ?? 0
        mHint.frame = CGRect(x: x, y: mCaption.maxY + 11.scaled, width: w, height: h)
        mField.frame = CGRect(x: x, y: ceil(mHint.maxY + 12.scaled), width: w, height: 60.scaled)
        
        let h2 = mBottom.text?.heightFor(width: w, font: mBottom.font) ?? 0
        mBottom.frame = CGRect(x: x, y: mField.maxY + 19.scaled, width: w, height: h2)
    }
    
}

