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
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private let mContent = UIView().apply({
        $0.backgroundColor = Style.Colors.white
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 14.scaled
        $0.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner]
    })
    
    var content: UIView {
        return mContent
    }
    
    var dragable: Bool {
        return true
    }
    
    var topGap: CGFloat {
        return 80
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
        if dragable {
            mContent.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(PopupVC.panned(_:))))
        }
    }

    @objc func panned(_ s: UIPanGestureRecognizer) {
        let newFraction = s.translation(in: view).y / view.height
        switch s.state {
        case .began:
            mCloseAnimation = false
            mAnimator.stopAnimation(true)
            mAnimator = UIViewPropertyAnimator(duration: 0.5, curve: .easeInOut, animations: { [weak self] in
                if let s = self {
                    s.mBlur.effect = nil
                    s.mContent.transform = CGAffineTransform(translationX: 0, y: s.view.height)
                }
            })
            mAnimator.startAnimation()
            mAnimator.pauseAnimation()
        case .changed:
            if newFraction < 0 {
                mCloseAnimation = false
                mAnimator.fractionComplete = 0.0
                s.setTranslation(.zero, in: mContent)
            } else {
                mCloseAnimation = mAnimator.fractionComplete < newFraction
                mAnimator.fractionComplete = newFraction
            }
        case .cancelled: fallthrough
        case .ended:
            mAnimator.isReversed = !mCloseAnimation
            if mCloseAnimation {
                AppDelegate.lock()
                mAnimator.addCompletion { [weak self] (p) in
                    if let s = self, s.mCloseAnimation {
                        s.dismiss(animated: false, completion: nil)
                    }
                    AppDelegate.unlock()
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
        let size = doLayout()
        let vert = min(view.height - topGap, size)
        mContent.frame = CGRect(x: 0, y: view.height - vert, width: view.width, height: vert + 100)
        mContent.transform = trans
    }
    
    public func doLayout() -> CGFloat {
        return 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !animated {
            mBlur.effect = UIBlurEffect(style: .dark)
        }
        setNeedsStatusBarAppearanceUpdate()
    }

    // MARK: - UIViewControllerTransitioningDelegate methods
    // -------------------------------------------------------------------------
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
        mBlur.effect = nil
        container.addSubview(view)
        view.setNeedsLayout()
        view.layoutIfNeeded()
        AppDelegate.lock()
        
        UIView.animate(withDuration: 0.5, delay: 0.25, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.0, options: [], animations: {
            self.mContent.transform = .identity
        }, completion: { _ in
            AppDelegate.unlock()
            completion()
        })
        UIView.animate(withDuration: 0.25, animations: {
            self.mBlur.effect = UIBlurEffect(style: .dark)
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
