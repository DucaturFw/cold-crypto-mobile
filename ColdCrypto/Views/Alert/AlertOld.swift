//
//  AlertOld.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 26/11/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import Foundation

import UIKit

class AlertOld: UIView, UITextFieldDelegate {
    
    enum Style {
        case withText, withField, withFieldCamera
    }
    
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
        get {
            return (mField.field.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        }
        set {
            mField.field.text = newValue
        }
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
    var field: Field {
        return mField
    }
    
    private let mIcon = UIImageView(image: UIImage(named: "qrSmall")).apply({
        $0.backgroundColor = .white
        $0.layer.borderWidth = 1.0
        $0.layer.borderColor = 0xDFDFDF.color.cgColor
        $0.layer.cornerRadius = 6
        $0.contentMode = .center
    })
    
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
    
    private let mCustomContainer = UIView().apply({
        $0.clipsToBounds = true
    })
    
    private var mCustomView: UIView?
    var customView: UIView? {
        return mCustomView
    }
    
    private var mOnScan: (AlertOld)->Void = { _ in }
    
    init(message: String, style: Style = .withText) {
        super.init(frame: UIScreen.main.bounds)
        mBlur.isUserInteractionEnabled = false
        mBlur.effect = nil
        addSubview(mBlur)
        addSubview(mOverlay)
        addSubview(mBox)
        addSubview(mPositive)
        addSubview(mNegative)
        mBox.addSubview(mName)
        mBox.addSubview(mCustomContainer)
        
        if style == .withField || style == .withFieldCamera {
            mBox.addSubview(mField)
            mField.field.returnKeyType = .done
            mField.field.delegate = self
            
            if style == .withFieldCamera {
                mBox.addSubview(mIcon)
                mIcon.tap({ [weak self] in
                    if let s = self {
                        s.mOnScan(s)
                    }
                })
            }
        }
        
        mName.isVisible = true
        mName.text = message
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    func onScan(do block: @escaping (AlertOld)->Void) -> Self {
        mOnScan = block
        return self
    }
    
    func set(positive: String, hide: Bool = true, do block: ((AlertOld)->Void)? = nil) -> Self {
        mPositive.setTitle(positive, for: .normal)
        mPositive.isVisible = true
        mPositive.click = { [weak self] in
            if let s = self {
                block?(s)
                if hide {
                    s.hide()
                }
            }
        }
        return self
    }
    
    func set(negative: String, hide: Bool = true, do block: ((AlertOld)->Void)? = nil) -> Self {
        mNegative.setTitle(negative, for: .normal)
        mNegative.isVisible = true
        mNegative.click = { [weak self] in
            if let s = self {
                block?(s)
                if hide {
                    s.hide()
                }
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
            self.mBlur.effect = UIBlurEffect(style: .dark)
            self.state = .shown
        }, completion: { _ in
            self.mIsInAnimation = false
            if self.mField.superview != nil {
                self.mField.field.becomeFirstResponder()
            }
        })
    }
    
    @discardableResult
    func set(customView: UIView?, animated: Bool) -> Self {
        mCustomView = customView
        
        let block: ()->Void = { [weak self] in
            if let s = self, let cv = s.mCustomView {
                cv.frame = CGRect(x: 0, y: 0, width: s.mCustomContainer.width, height: cv.height)
                s.mCustomContainer.addSubview(cv)
                if animated {
                    UIView.animate(withDuration: 0.25, animations: {
                        s.mCustomContainer.alpha = 1.0
                        s.setNeedsLayout()
                        s.layoutIfNeeded()
                    })
                } else {
                    s.mCustomContainer.alpha = 1.0
                    s.setNeedsLayout()
                    s.layoutIfNeeded()
                }
            }
        }
        if mCustomContainer.subviews.count > 0 {
            if animated {
                UIView.animate(withDuration: 0.25, animations: {
                    self.mCustomContainer.alpha = 0.0
                }, completion: { _ in
                    self.mCustomContainer.subviews.forEach({
                        $0.removeFromSuperview()
                    })
                    block()
                })
            } else {
                self.mCustomContainer.subviews.forEach({
                    $0.removeFromSuperview()
                })
                block()
            }
        } else {
            block()
        }
        
        return self
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
        let txtSize = ceil((mName.text?.heightFor(width: mBox.width - padding * 2, font: mName.font) ?? 0.0))
        var bottom  = padding
        
        mName.frame = CGRect(x: padding, y: bottom, width: mBox.width - padding * 2, height: txtSize)
        bottom = mName.maxY + padding
        
        if mField.superview != nil {
            
            let w = CGFloat(mIcon.superview != nil ? 55.0 : 0.0)
            
            mField.frame = CGRect(x: padding, y: bottom, width: mBox.width - w - padding*2.0, height: 45)
            
            if mIcon.superview != nil {
                mIcon.frame = CGRect(x: mField.maxX + 10, y: mField.minY, width: 45, height: 45)
            }
            
            bottom = mField.maxY + padding
        }
        
        if let fv = mCustomContainer.subviews.first {
            fv.frame = CGRect(x: 0, y: 0, width: mBox.width, height: fv.height)
            mCustomContainer.frame = CGRect(x: 0, y: bottom, width: mBox.width, height: fv.maxY)
            bottom = mCustomContainer.maxY + padding
        } else {
            mCustomContainer.frame = CGRect(x: 0, y: bottom, width: mBox.width, height: 0)
        }
        
        let allHeight = bottom + (mPositive.isVisible || mNegative.isVisible ? 60 : 0)
        mBox.frame = CGRect(x: (width - mBox.width)/2.0, y: (height - allHeight)/2.0, width: mBox.width, height: bottom)
        
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
