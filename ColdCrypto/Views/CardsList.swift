//
//  CardsList.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 31/10/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import UIKit
import TGLStackedViewController

class CardsList: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegate {
    
    private var mSelected: IndexPath?
    
    var onBackUp: (IWallet)->Void = { _ in }
    
    var onDelete: (IWallet)->Void = { _ in }
    
    var onActive: (IWallet?)->Void = { _ in }
    
    private var mReversedWallets: [IWallet] = [IWallet]()
    var wallets: [IWallet] = [] {
        didSet {
            mReversedWallets = wallets.reversed()
            reloadData()
        }
    }
    
    var detailsForCard: Bool = true
    
    private lazy var mTap = UITapGestureRecognizer(target: self, action: #selector(hideTapped))
    
    private lazy var mPan = UIPanGestureRecognizer(target: self, action: #selector(panned(_:)))
    
    var bottom: CGFloat {
        get {
            return mLayout.layoutMargin.bottom
        }
        set {
            mLayout.layoutMargin.bottom = newValue
        }
    }
    
    var top: CGFloat {
        get {
            return mLayout.layoutMargin.top
        }
        set {
            mLayout.layoutMargin.top = newValue
        }
    }
    
    private let mLayout: TGLStackedLayout = {
        let wid = UIScreen.main.bounds.width
        let tmp = TGLStackedLayout()
        tmp.itemSize  = CGSize(width: wid, height: wid / 270.0 * 160.0)
        tmp.topReveal = 87.scaled
        tmp.layoutMargin = UIEdgeInsets(top: UIApplication.shared.statusBarFrame.height + 44.0, left: 0, bottom: 0, right: 0)
        tmp.isAlwaysBouncing = true
        return tmp
    }()

    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: mLayout)
        backgroundView  = UIView()
        backgroundColor = .clear
        dataSource = self
        delegate = self
        register(WalletView.self, forCellWithReuseIdentifier: "cell")
        WalletView.register(in: self)
        contentInsetAdjustmentBehavior = .never
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    func add(wallet: IWallet) {
        let completion = {
            UIApplication.shared.beginIgnoringInteractionEvents()
            self.performBatchUpdates({
                self.mReversedWallets.insert(wallet, at: 0)
                self.wallets.append(wallet)
                self.insertItems(at: [IndexPath(item: 0, section: 0)])
            }, completion: { _ in
                UIApplication.shared.endIgnoringInteractionEvents()
                self.setContentOffset(.zero, animated: true)
            })
        }
        
        if let a = set(selected: nil) {
            a.addCompletion({ _ in
                completion()
            })
        } else {
            completion()
        }
    }
    
    func delete(wallet: IWallet) {
        UIApplication.shared.beginIgnoringInteractionEvents()
        performBatchUpdates({
            var i = [IndexPath]()
            self.mReversedWallets.enumerated().forEach({
                if wallet.privateKey == $0.element.privateKey {
                    i.append(IndexPath(item: $0.offset, section: 0))
                }
            })
            if i.count > 0 {
                self.mReversedWallets.removeAll(where: { $0.address == wallet.address })
                self.wallets.removeAll(where: { $0.address == wallet.address })
                self.deleteItems(at: i)
            }
        }, completion: { _ in
            UIApplication.shared.endIgnoringInteractionEvents()
        })
    }
    
    @discardableResult
    private func set(selected: IndexPath?) -> UIViewPropertyAnimator? {
        let anim: UIViewPropertyAnimator?
        if let s = selected, let newLayout = TGLExposedLayout(exposedItemIndex: s.item) {
            mLayout.contentOffset = contentOffset;
            mActive = wallets[s.row]
            mPrevLayout = newLayout
            newLayout.layoutMargin = mLayout.layoutMargin
            newLayout.itemSize = mLayout.itemSize
            newLayout.bottomPinningCount = 0
            newLayout.topPinningCount = 0
            AppDelegate.lock()
            anim = UIViewPropertyAnimator(duration: 0.35, curve: .easeInOut, animations: { [weak self] in
                self?.showFirst(newLayout: newLayout, s: s, wallet: self?.mActive)
            })
            anim?.addCompletion({ [weak self] _ in
                self?.showLast(s: s)
                AppDelegate.unlock()
            })
            anim?.startAnimation()
            addGestureRecognizer(mTap)
            addGestureRecognizer(mPan)
        } else if let s = mSelected {
            AppDelegate.lock()
            mActive = nil
            anim = UIViewPropertyAnimator(duration: 0.35, curve: .easeInOut, animations: { [weak self] in
                self?.hideFirst(s: s)
            })
            anim?.addCompletion({ [weak self] _ in
                self?.hideLast()
                AppDelegate.unlock()
            })
            anim?.startAnimation()
            removeGestureRecognizer(mTap)
            removeGestureRecognizer(mPan)
        } else {
            anim = nil
        }
        return anim
    }

    private func hideFirst(s: IndexPath) {
        (cellForItem(at: s) as? WalletView)?.fullVisible = false
        setCollectionViewLayout(mLayout, animated: true, completion: nil)
        onActive(nil)
    }
    
    private func hideLast() {
        mLayout.overwriteContentOffset = false
        mSelected = nil
    }
    
    private func showFirst(newLayout: TGLExposedLayout, s: IndexPath, wallet: IWallet?) {
        (cellForItem(at: s) as? WalletView)?.fullVisible = detailsForCard
        setCollectionViewLayout(newLayout, animated: true, completion: nil)
        onActive(wallet)
    }
    
    private func showLast(s: IndexPath) {
        mLayout.overwriteContentOffset = true
        mSelected = s
    }
    
    @objc private func hideTapped() {
        set(selected: nil)
    }
    
    private var mCloseAnimation = false
    private var mAnimator = UIViewPropertyAnimator()
    private var mPrevLayout: TGLExposedLayout?
    private var mActive: IWallet?
    
    @objc private func panned(_ s: UIPanGestureRecognizer) {
        guard let selected = mSelected else { return }
        let newFraction = s.translation(in: self).y / height
        switch s.state {
        case .began:
            mCloseAnimation = false
            mAnimator = UIViewPropertyAnimator(duration: 0.5, curve: .easeInOut, animations: { [weak self] in
                self?.hideFirst(s: selected)
            })
            mAnimator.startAnimation()
            mAnimator.pauseAnimation()
        case .changed:
            if newFraction < 0 {
                mCloseAnimation = false
                mAnimator.fractionComplete = 0.0
                s.setTranslation(.zero, in: self)
            } else {
                mCloseAnimation = mAnimator.fractionComplete < newFraction
                mAnimator.fractionComplete = newFraction
            }
        case .ended:
            mAnimator.isReversed = !mCloseAnimation
            AppDelegate.lock()
            if mCloseAnimation {
                mAnimator.addCompletion { [weak self] (p) in
                    self?.hideLast()
                    AppDelegate.unlock()
                }
                removeGestureRecognizer(mPan)
                removeGestureRecognizer(mTap)
            } else {
                mAnimator.addCompletion { [weak self] (p) in
                    if let cv = self?.mPrevLayout {
                        self?.showFirst(newLayout: cv, s: selected, wallet: self?.mActive)
                    }
                    AppDelegate.unlock()
                }
            }
            mAnimator.startAnimation()
        default: break
        }
    }
    
    func close(completion: @escaping ()->Void) {
        set(selected: nil)?.addCompletion({ _ in
            completion()
        })
    }

    // MARK: - UICollectionViewDataSource methods
    // -------------------------------------------------------------------------
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return wallets.count
    }
    
    func collectionView(_ cv: UICollectionView, cellForItemAt p: IndexPath) -> UICollectionViewCell {
        let cell = WalletView.get(from: cv, at: p)
        cell.wallet = mReversedWallets[p.row]
        cell.onBackUp = { [weak self] w in
            self?.onBackUp(w)
        }
        cell.onDelete = { [weak self] w in
            self?.onDelete(w)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        set(selected: indexPath.item == mSelected?.item ? nil : indexPath)
    }
    
}
