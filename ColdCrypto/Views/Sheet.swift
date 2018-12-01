//
//  Sheet.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 10/11/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import UIKit

class Sheet : UIView {
    
    private let mBlur = UIVisualEffectView()
    
    private var mButtons: [Button] = []
    
    private let mCancel: Button = {
        let tmp = Button()
        tmp.backgroundColor = 0x1888FE.color
        tmp.layer.cornerRadius = 6
        tmp.setTitle("cancel".loc, for: .normal)
        tmp.layer.shadowColor = 0xB8CEFD.color.cgColor
        tmp.layer.shadowOffset = CGSize(width: 0, height: 10)
        tmp.layer.shadowRadius = 10
        tmp.layer.shadowOpacity = 0.1
        return tmp
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        mBlur.isUserInteractionEnabled = false
        mBlur.effect = nil
        addSubview(mBlur)
        addSubview(mCancel)
        mCancel.click = { [weak self] in
            self?.hide()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    @discardableResult
    func appned(_ name: String, do block: ((Sheet)->Void)? = nil) -> Self {
        let tmp = Button()
        tmp.backgroundColor = Style.Colors.white
        tmp.layer.cornerRadius = 6
        tmp.setTitle(name, for: .normal)
        tmp.setTitleColor(0x1888FE.color, for: .normal)
        tmp.layer.shadowColor = UIColor.black.cgColor
        tmp.layer.shadowOffset = CGSize(width: 0, height: 10)
        tmp.layer.shadowRadius = 10
        tmp.layer.shadowOpacity = 0.1
        tmp.click = { [weak self] in
            if let s = self {
                block?(s)
                s.hide()
            }
        }
        addSubview(tmp)
        mButtons.append(tmp)
        return self
    }
    
    func show() {
        guard let w = UIApplication.shared.windows.first else { return }
        mButtons.append(mCancel)
        show(in: w)
    }
    
    private func show(in window: UIView) {
        frame = window.bounds
        window.addSubview(self)
        mBlur.effect = nil
        
        forceLayout()
        
        let h = 10 + 45
        let t = height - CGFloat(mButtons.count * h) - AppDelegate.bottomGap - 20
        let l = mButtons.count - 1
        mButtons.enumerated().forEach { i in
            i.element.frame = CGRect(x: (width - 270)/2.0,
                                     y: CGFloat(t) + CGFloat(h * i.offset) + (i.offset == l ? 10 : 0),
                                     width: 270, height: 45)
            i.element.transform = CGAffineTransform(translationX: 0, y: i.element.minY)
            UIView.animate(withDuration: 0.3,
                           delay: TimeInterval(i.offset) * 0.1,
                           options: .curveEaseInOut,
                           animations: {
                            i.element.transform = .identity
            }, completion: nil)
        }
        
        UIView.animate(withDuration: 0.4, animations: {
            self.mBlur.effect = UIBlurEffect(style: .dark)
        })
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        forceLayout()
    }
    
    private func forceLayout() {
        mBlur.frame = bounds
    }
    
    @objc func hide() {
        let m = mButtons.count - 1
        mButtons.reversed().enumerated().forEach { i in
            UIView.animate(withDuration: 0.3,
                           delay: TimeInterval(i.offset) * 0.1,
                           options: .curveEaseInOut,
                           animations: {
                            i.element.transform = CGAffineTransform(translationX: 0, y: i.element.minY)
            }, completion: { _ in
                if i.offset == m {
                    self.removeFromSuperview()
                }
            })
        }
        
        UIView.animate(withDuration: 0.3 + 0.1 * Double(mButtons.count - 1), animations: {
            self.mBlur.effect = nil
        })
        
    }
    
    // MARK:- UITextFieldDelegate methods
    // -------------------------------------------------------------------------
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return false
    }
    
}
