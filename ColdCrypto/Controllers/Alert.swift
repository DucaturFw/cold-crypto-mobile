//
//  Alert.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 20/10/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import UIKit

class Alert : UIView, UITextFieldDelegate {
    
    enum State {
        case hidden, shown
    }
    
    var boxWidth: CGFloat {
        return 270.0
    }
    
    var boxHeight: CGFloat {
        return 300.0
    }
    
    private var state: State = .hidden {
        didSet {
            updateState()
        }
    }
    
    var value: String {
        return (mField.field.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private var mIsInAnimation: Bool = true
    
    private let mBlur = UIVisualEffectView()
    
    private lazy var mName = UILabel.new(font: UIFont.sfProSemibold(17), text: "", lines: 0, color: 0x32325D.color, alignment: .center)
    
    private var mOverlay: UIView = {
        let tmp = UIView(frame: UIScreen.main.bounds)
        tmp.backgroundColor = UIColor.black.withAlphaComponent(0.05)
        tmp.alpha = 0.0
        return tmp
    }()
    
    private lazy var mBox: UIView = { [weak self] in
        let tmp = UIView(frame: CGRect(x: 0, y: 0, width: self?.boxWidth ?? 300, height: self?.boxHeight ?? 300))
        tmp.backgroundColor = .white
        tmp.layer.cornerRadius = 6
        tmp.layer.shadowColor = 0x44519E.color.cgColor
        tmp.layer.shadowOffset = CGSize(width: 0, height: 10)
        tmp.layer.shadowRadius = 10
        tmp.layer.shadowOpacity = 0.3
        return tmp
        }()
    
    private let mField = Field(name: "")
    
    private let mPositive: Button = {
        let tmp = Button()
        tmp.isVisible = false
        tmp.backgroundColor = 0x1888FE.color
        tmp.layer.cornerRadius = 6
        tmp.layer.shadowColor = 0xB8CEFD.color.cgColor
        tmp.layer.shadowOffset = CGSize(width: 0, height: 10)
        tmp.layer.shadowRadius = 10
        tmp.layer.shadowOpacity = 0.3
        return tmp
    }()
    
    private let mNegative: Button = {
        let tmp = Button()
        tmp.isVisible = false
        tmp.backgroundColor = 0x26E7B0.color
        tmp.layer.cornerRadius = 6
        tmp.layer.shadowColor = 0x8DFFB6.color.cgColor
        tmp.layer.shadowOffset = CGSize(width: 0, height: 10)
        tmp.layer.shadowRadius = 10
        tmp.layer.shadowOpacity = 0.3
        return tmp
    }()
    
    init(message: String, withField: Bool = false) {
        super.init(frame: UIScreen.main.bounds)
        mBlur.isUserInteractionEnabled = false
        mBlur.effect = nil
        addSubview(mBlur)
        addSubview(mOverlay)
        addSubview(mBox)
        addSubview(mPositive)
        addSubview(mNegative)
        mBox.addSubview(mName)
        
        if withField {
            mBox.addSubview(mField)
            mField.field.returnKeyType = .done
            mField.field.delegate = self
        }
        
        mName.isVisible = true
        mName.text = message
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    func set(positive: String, do block: ((Alert)->Void)? = nil) -> Self {
        mPositive.setTitle(positive, for: .normal)
        mPositive.isVisible = true
        mPositive.click = { [weak self] in
            if let s = self {
                block?(s)
                s.hide()
            }
        }
        return self
    }
    
    func set(negative: String, do block: ((Alert)->Void)? = nil) -> Self {
        mNegative.setTitle(negative, for: .normal)
        mNegative.isVisible = true
        mNegative.click = { [weak self] in
            if let s = self {
                block?(s)
                s.hide()
            }
        }
        return self
    }
    
    func show() {
        guard let w = UIApplication.shared.windows.first else { return }
        show(in: w)
    }
    
    func show(in window: UIView) {
        frame = window.bounds
        window.addSubview(self)
        mBlur.effect = nil
        
        forceLayout()
        updateState()
        
        mIsInAnimation = true
        UIView.animate(withDuration: 0.6, delay: 0.2, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: [], animations: {
            self.mBlur.effect = UIBlurEffect(style: .regular)
            self.state = .shown
        }, completion: { _ in
            self.mIsInAnimation = false
            if self.mField.superview != nil {
                self.mField.field.becomeFirstResponder()
            }
        })
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if (mIsInAnimation) { return }
        forceLayout()
    }
    
    private func forceLayout() {
        mBlur.frame = bounds
        mOverlay.frame = bounds
        
        let padding = CGFloat(20)
        let txtHeight = ceil((mName.text?.heightFor(width: mBox.width - padding * 2, font: mName.font) ?? 0.0))
        mName.frame = CGRect(x: padding, y: padding, width: mBox.width - padding * 2, height: txtHeight)
        
        let boxHeight = txtHeight + padding * 2 + (mField.superview != nil ? 60 : 0)
        
        if mField.superview != nil {
            mField.frame = CGRect(x: padding, y: boxHeight - padding - 45, width: mBox.width - padding*2.0, height: 45)
        }
        
        let allHeight = boxHeight + (mPositive.isVisible || mNegative.isVisible ? 60 : 0)
        
        mBox.frame = CGRect(x: (width - mBox.width)/2.0, y: (height - allHeight)/2.0, width: mBox.width, height: boxHeight)
        
        if mPositive.isVisible && mNegative.isVisible {
            let w = (mBox.width - 10) / 2.0
            mNegative.frame = CGRect(x: mBox.minX, y: mBox.maxY + 15, width: w, height: 45)
            mPositive.frame = CGRect(x: mBox.maxX - w, y: mNegative.minY, width: w, height: 45)
        } else {
            let v = mPositive.isVisible ? mPositive : mNegative
            v.frame = CGRect(x: mBox.minX, y: mBox.maxY + 15, width: mBox.width, height: 45)
        }
    }
    
    func updateState() {
        mBox.transform = CGAffineTransform(translationX: 0, y: state == .shown ? 0 : height)
        mPositive.transform = mBox.transform
        mNegative.transform = mBox.transform
        mOverlay.alpha = state == .shown ? 1.0 : 0.0
    }
    
    @objc func hide() {
        mIsInAnimation = true
        UIView.animate(withDuration: 0.4, animations: {
            self.mBlur.effect = nil
            self.state = .hidden
        }) { (_) in
            self.mIsInAnimation = false
            self.removeFromSuperview()
        }
    }
    
    // MARK:- UITextFieldDelegate methods
    // -------------------------------------------------------------------------
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return false
    }
    
}
