//
//  PopupVC.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 05/11/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import UIKit

class PopupVC: UIViewController, UIViewControllerTransitioningDelegate, IPopover {
    
    private lazy var mTransition = PopAnimator(root: self)
    
    private var mCloseAnimation = false
    
    private let mContent = UIView().apply({
        $0.backgroundColor = .white
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 10.scaled
        $0.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner]
    })
    
    private let mBG = UIImageView(image: UIImage(named: "mainBG")).apply({
        $0.contentMode   = .scaleAspectFill
        $0.clipsToBounds = true
    })
    
    var content: UIView {
        return mContent
    }
    
    private let mBlur: UIVisualEffectView = UIVisualEffectView(effect: nil)
    
    private var mAnimator = UIViewPropertyAnimator()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        transitioningDelegate  = self
        modalPresentationStyle = .custom
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(mBlur)
        mBlur.contentView.addSubview(mContent)
        mContent.addSubview(mBG)
        mContent.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(PopupVC.panned(_:))))
    }

    @objc private func panned(_ s: UIPanGestureRecognizer) {
        let newFraction = s.translation(in: mContent).y / mContent.height
        if newFraction < 0 {
            mAnimator.fractionComplete = 0.0
            s.setTranslation(.zero, in: mContent)
            return
        }
        switch s.state {
        case .began:
            mCloseAnimation = false
            mAnimator = UIViewPropertyAnimator(duration: 0.5, curve: .easeInOut, animations: { [weak self] in
                if let s = self {
                    s.mBlur.effect = nil
                    s.mContent.transform = CGAffineTransform(translationX: 0, y: s.view.height)
                }
            })
            mAnimator.startAnimation()
            mAnimator.pauseAnimation()
        case .changed:
            mCloseAnimation = mAnimator.fractionComplete < newFraction
            mAnimator.fractionComplete = newFraction
        case .cancelled: fallthrough
        case .ended:
            mAnimator.isReversed = !mCloseAnimation
            if mCloseAnimation {
                mAnimator.addCompletion { [weak self] (p) in
                    if let s = self, s.mCloseAnimation {
                        s.dismiss(animated: false, completion: nil)
                    }
                }
            }
            mAnimator.startAnimation()
        default: break
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        mBlur.frame = view.bounds
        let trans = mContent.transform
        mContent.transform = .identity
        mContent.frame = CGRect(x: 0, y: 80, width: view.width, height: view.height - 80)
        mBG.frame = content.bounds
        mContent.transform = trans
    }

    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        mTransition.presenting = true
        return mTransition
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        mTransition.presenting = false
        return mTransition
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return UIPresentationController(presentedViewController: presented, presenting: presenting)
    }
    
    // MARK: - IPopover methods
    // -------------------------------------------------------------------------
    func show(container: UIView, completion: @escaping ()->Void) {
        view.frame = container.bounds
        mContent.transform = CGAffineTransform(translationX: 0, y: container.height)
        container.addSubview(view)
        view.setNeedsLayout()
        view.layoutIfNeeded()
        AppDelegate.lock()
        UIView.animate(withDuration: 0.4, animations: {
            self.mBlur.effect = UIBlurEffect(style: .extraLight)
            self.mContent.transform = .identity
        }, completion: { _ in
            AppDelegate.unlock()
            completion()
        })
    }
    
    func hide(completion: @escaping  ()->Void) {
        AppDelegate.lock()
        UIView.animate(withDuration: 0.4, animations: {
            self.mBlur.effect = nil
            self.mContent.transform = CGAffineTransform(translationX: 0, y: self.view.height)
        }, completion: { _ in
            AppDelegate.unlock()
            completion()
        })
    }
    
}
