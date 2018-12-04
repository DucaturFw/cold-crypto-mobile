//
//  PopupVC.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 05/11/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import UIKit

extension Notification.Name {
    static let hideAllPopups: Notification.Name = NSNotification.Name(rawValue: "_hideAllPopups")
}

class PopupVC: UIViewController, UIViewControllerTransitioningDelegate, IPopover {
    
    enum PresentationStyle {
        case alert, sheet
    }
    
    class EmptyVC: UIViewController {
        
        private weak var mParent: UIViewController?
        
        override var preferredStatusBarStyle: UIStatusBarStyle {
            return mParent?.preferredStatusBarStyle ?? .lightContent
        }
        
        init(_ vc: UIViewController) {
            super.init(nibName: nil, bundle: nil)
            mParent = vc
        }
        
        required init?(coder aDecoder: NSCoder) {
            return nil
        }
        
    }
    
    static func hideAll() {
        NotificationCenter.default.post(name: .hideAllPopups, object: nil)
    }
    
    private var alertWindow: UIWindow?
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        alertWindow?.removeFromSuperview()
        alertWindow?.isHidden = true
        alertWindow = nil
    }
    
    private lazy var mTransition = PopAnimator(root: self)
    
    private var mCloseAnimation = false
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @objc func hide() {
        dismiss(animated: true, completion: nil)
    }

    func show() {
        guard let w = UIApplication.shared.windows.first else { return }
        show(in: w)
    }
    
    @objc private func hideForce() {
        dismiss(animated: false, completion: nil)
    }
    
    func show(in window: UIView) {
        if alertWindow != nil { return }
        alertWindow = UIWindow(frame: UIScreen.main.bounds)
        alertWindow?.layer.cornerRadius  = 10.scaled
        alertWindow?.layer.masksToBounds = true
        alertWindow?.rootViewController  = EmptyVC(self)
        alertWindow?.windowLevel = UIWindow.Level(rawValue: (UIApplication.shared.windows.last?.windowLevel.rawValue ?? 0.0) + 1.0)
        alertWindow?.makeKeyAndVisible()
        alertWindow?.rootViewController?.present(self, animated: true, completion: nil)
    }
    
    private let mContent = UIView().apply({
        $0.backgroundColor = Style.Colors.white
        $0.layer.cornerRadius = 14.scaled
        $0.clipsToBounds = true
        $0.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    })
    
    var content: UIView {
        return mContent
    }
    
    var dragable: Bool {
        return true
    }
    
    var width: CGFloat {
        return style == .sheet ? view.width : 300
    }
    
    private let mBlur = UIView()

    private var mAnimator = UIViewPropertyAnimator()
    
    var style: PresentationStyle = .sheet
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideForce), name: .hideAllPopups, object: nil)
        transitioningDelegate  = self
        modalPresentationStyle = .custom
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(mBlur)
        mBlur.addSubview(mContent)
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
                    s.mBlur.backgroundColor = .clear
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
        
        if style == .sheet {
            let vert = min(view.height - 80, size) + AppDelegate.bottomGap
            mContent.frame = CGRect(x: (view.width - width)/2.0, y: view.height - vert, width: width, height: vert + 100)
        } else {
            let vert = min(view.height, size)
            mContent.frame = CGRect(x: (view.width - width)/2.0, y: (view.height - vert)/2.0, width: width, height: vert)
        }

        mContent.transform = trans
    }
    
    public func doLayout() -> CGFloat {
        return 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !animated {
            mBlur.backgroundColor = Style.Colors.tint
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
        mBlur.backgroundColor = .clear
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
            self.mBlur.backgroundColor = Style.Colors.tint
        })
    }
    
    func hide(completion: @escaping  ()->Void) {
        AppDelegate.lock()
        UIView.animate(withDuration: 0.4, animations: {
            self.mBlur.backgroundColor = .clear
            self.mContent.transform = CGAffineTransform(translationX: 0, y: self.view.height)
        }, completion: { _ in
            AppDelegate.unlock()
            completion()
        })
    }
    
}
