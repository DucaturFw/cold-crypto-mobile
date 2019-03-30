//
//  EmptyVC.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 04/03/2019.
//  Copyright © 2019 Kirill Kozhuhar. All rights reserved.
//

import Foundation

class CustomW: UIWindow {
    
    var onWillRemoveView: (UIView)->Void = { _ in }
    
    override func willRemoveSubview(_ subview: UIView) {
        super.willRemoveSubview(subview)
        onWillRemoveView(subview)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.masksToBounds = true
        layer.cornerRadius = 9
        layer.isOpaque = false
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
    }
    
}

extension UIViewController {
    func show(animated: Bool = true) {
        let w = CustomW(frame: UIScreen.main.bounds)
        w.layer.masksToBounds = true
        w.rootViewController  = EmptyVC(self, window: w)
        w.windowLevel = UIWindow.Level.normal
        w.makeKeyAndVisible()
        w.rootViewController?.present(self, animated: animated, completion: nil)
    }
}

class EmptyVC: UIViewController {
    
    private weak var mParent: UIViewController?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if let p = presentedViewController, !p.isBeingDismissed {
            return p.preferredStatusBarStyle
        }
        return .lightContent
    }
    
    private var mWin: CustomW?
    
    init(_ vc: UIViewController, window: CustomW) {
        mWin = window
        mParent = vc
        super.init(nibName: nil, bundle: nil)
        
        mWin?.onWillRemoveView = { [weak self] v in
            DispatchQueue.main.async {
                if self?.presentedViewController == nil {
                    self?.mWin?.isHidden = true
                    self?.mWin = nil
                }
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
}
