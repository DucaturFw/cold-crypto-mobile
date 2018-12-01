//
//  PasswordVC.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 01/11/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import UIKit

class PasswordVC: UIViewController {
    
    private let mBG = UIImageView(image: UIImage(named: "mainBG")).apply({
        $0.contentMode = .scaleAspectFill
    })
    
    private lazy var mCancel = UILabel.new(font: UIFont.hnMedium(18.scaled),
                                           text: "cancel".loc,
                                           lines: 1,
                                           color: Style.Colors.blue,
                                           alignment: .center).apply({
                                            $0.frame = $0.frame.insetBy(dx: -18.0, dy: -2.0)
                                           }).tap({ [weak self] in
                                            self?.navigationController?.setViewControllers([AuthVC()], animated: true)
                                           })
    
    private lazy var mNext = UILabel.new(font: UIFont.hnMedium(18.scaled),
                                         text: "next".loc,
                                         lines: 1,
                                         color: Style.Colors.blue,
                                         alignment: .center).apply({
                                            $0.frame = $0.frame.insetBy(dx: -18.0, dy: -2.0)
                                         }).tap({ [weak self] in
                                            if let pass = self?.mField.text, pass.count > 0, let passcode = self?.mPasscode {
                                                self?.navigationController?.pushViewController(RepeatPassVC(password: pass,
                                                                                                            passcode: passcode), animated: true)
                                            }
                                         })
    
    private let mCaption = UILabel.new(font: UIFont.hnBold(36.scaled), text: "pick_pass".loc, lines: 0, color: Style.Colors.blue, alignment: .left)
    
    private let mHint = UILabel.new(font: UIFont.hnMedium(20.scaled), text: "pass_hint".loc, lines: 0, color: .black, alignment: .left)
    
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
        $0.backgroundColor = Style.Colors.blue
        $0.layer.cornerRadius = 12.scaled
        $0.isSecureTextEntry = true
    })
    
    private let mBottom = UILabel.new(font: UIFont.hnRegular(18.scaled), text: "pass_bottom".loc, lines: 0, color: 0x9B9B9B.color, alignment: .left)
    
    private let mPasscode: String
    
    init(passcode: String) {
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
        mField.addTarget(self, action: #selector(textChanged), for: .editingChanged)
        textChanged()
    }
    
    @objc private func textChanged() {
        if (mField.text?.count ?? 0) > 0 {
            mNext.isUserInteractionEnabled = true
            mNext.textColor = Style.Colors.blue
        } else {
            mNext.isUserInteractionEnabled = false
            mNext.textColor = Style.Colors.darkLight
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
        mCancel.origin = CGPoint(x: 0, y: t - 22 - mCancel.height/2.0)
        mNext.origin = CGPoint(x: view.width - mNext.width, y: mCancel.minY)

        let w = view.width - x * 2.0
        let h = mHint.text?.heightFor(width: w, font: mHint.font) ?? 0
        mHint.frame = CGRect(x: x, y: mCaption.maxY + 11.scaled, width: w, height: h)
        mField.frame = CGRect(x: x, y: ceil(mHint.maxY + 12.scaled), width: w, height: 60.scaled)
        
        let h2 = mBottom.text?.heightFor(width: w, font: mBottom.font) ?? 0
        mBottom.frame = CGRect(x: x, y: mField.maxY + 19.scaled, width: w, height: h2)
    }
    
}
