//
//  BlockchainPickerVC.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 07/11/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import UIKit

class BlockchainPickerVC: UIViewController, IPopover, UIViewControllerTransitioningDelegate, UITableViewDelegate, UITableViewDataSource {
    
    private struct Dims {
        static let width: CGFloat = 120.0
    }
    
    private let mItems = [
        UIImage(named: "btc"),
        UIImage(named: "dash"),
        UIImage(named: "eth"),
        UIImage(named: "eth2"),
        UIImage(named: "game"),
        UIImage(named: "gold"),
        UIImage(named: "lisk")
    ]
    
    private lazy var mTransition = PopAnimator(root: self)
    
    private let mBlur: UIVisualEffectView = UIVisualEffectView(effect: nil)
    
    private lazy var mContent = UITableView().apply({ [weak self] in
        BlockchainCell.register(in: $0)
        $0.backgroundColor = .white
        $0.separatorStyle = .none
        $0.estimatedRowHeight = 0
        $0.dataSource = self
        $0.rowHeight = 120
        $0.delegate = self
    })
    
    private var mCloseAnimation = false
    
    private var mAnimator = UIViewPropertyAnimator()
    
    var onSelected: ()->Void = {}
    
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
        view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(panned(_:))))
        mBlur.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapped(_:))))
        view.addSubview(mBlur)
        view.addSubview(mContent)
    }
    
    @objc private func tapped(_ s: UITapGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func panned(_ s: UIPanGestureRecognizer) {
        let newFraction = s.translation(in: view).x / view.width
        switch s.state {
        case .began:
            mCloseAnimation = false
            mAnimator.stopAnimation(true)
            mAnimator = UIViewPropertyAnimator(duration: 0.5, curve: .easeInOut, animations: { [weak self] in
                if let s = self {
                    s.mBlur.effect = nil
                    s.mContent.transform = CGAffineTransform(translationX: Dims.width, y: 0)
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
        mContent.frame = CGRect(x: view.width - Dims.width, y: 0, width: Dims.width, height: view.height)
        mContent.transform = trans
    }
    
    // MARK: - IPopover methods
    // -------------------------------------------------------------------------
    func show(container: UIView, completion: @escaping ()->Void) {
        view.frame = container.bounds
        mContent.transform = CGAffineTransform(translationX: Dims.width, y: 0)
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
            self.mContent.transform = CGAffineTransform(translationX: Dims.width, y: 0)
        }, completion: { _ in
            AppDelegate.unlock()
            completion()
        })
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
    
    // MARK: - UITableViewDelegate, UITableViewDataSource methods
    // -------------------------------------------------------------------------
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return BlockchainCell.get(from: tableView, at: indexPath).apply({
            $0.img.image = mItems[indexPath.row % mItems.count]
        })
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: {
                self.onSelected()
            })
        }
    }
    
}
