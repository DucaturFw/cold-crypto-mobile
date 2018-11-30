//
//  ChainPicker.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 25/11/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import UIKit

class ChainPicker: UIView {
    
    private let mBlur = UIVisualEffectView()
    
    private let mPicker = CryptoList()
    
    private var mDone: (Blockchain?)->Void = { _ in }
    
    @objc override var withTint: Bool {
        return false
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        mBlur.isUserInteractionEnabled = false
        mBlur.effect = nil
        addSubview(mBlur)
        addSubview(mPicker)
        tap({ [weak self] in
            self?.hide(blockchain: nil)
        })
        mPicker.onSelect = { [weak self] b in
            self?.hide(blockchain: b)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    func show(in vc: UIViewController, block: @escaping (Blockchain?)->Void) {
        mDone = block
        frame = vc.view.bounds
        mBlur.frame = bounds
        vc.view.addSubview(self)
        mPicker.frame = CGRect(x: 0, y: 0, width: width, height: mPicker.height)
        mPicker.setNeedsLayout()
        mPicker.layoutIfNeeded()
        let y: CGFloat
        if let nb = vc.navigationController?.navigationBar {
            y = nb.convert(CGPoint(x: 0, y: nb.height), to: self).y
        } else {
            y = 0
        }
        mPicker.transform = CGAffineTransform(translationX: 0, y: -mPicker.height + y)
        
        AppDelegate.lock()
        UIView.animate(withDuration: 0.35, animations: {
            self.mBlur.effect = UIBlurEffect(style: .dark)
        }, completion: { _ in
            AppDelegate.unlock()
        })
        UIView.animate(withDuration: 0.6, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: [], animations: {
            self.mPicker.transform = .identity
        }, completion: nil)
    }
    
    private func hide(blockchain: Blockchain?) {
        AppDelegate.lock()
        UIView.animate(withDuration: 0.35, animations: {
            self.mBlur.effect = nil
            self.mPicker.transform = CGAffineTransform(translationX: 0, y: -self.mPicker.height)
        }, completion: { _ in
            AppDelegate.unlock()
            self.removeFromSuperview()
        })
        mDone(blockchain)
    }
    
}
