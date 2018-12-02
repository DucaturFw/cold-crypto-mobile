//
//  CardsList.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 31/10/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import UIKit
import TGLStackedViewController

class CardsList: UIView, UICollectionViewDataSource, UICollectionViewDelegate {
    
    private var mSelected: IndexPath?
    
    var detailsForCard: Bool = true

    var onBackUp: (IWallet)->Void = { _ in }
    
    var onDelete: (IWallet)->Void = { _ in }
    
    var onActive: (IWallet?)->Void = { _ in }
    
    private let mBlur = UIVisualEffectView(effect: nil).apply({
        $0.isUserInteractionEnabled = false
    })
    
    private let mLayout: TGLStackedLayout = {
        let tmp = TGLStackedLayout()
        tmp.itemSize = WalletCell.cardSize(width: UIScreen.main.bounds.width)
        tmp.topReveal = 87.scaled
        tmp.layoutMargin = UIEdgeInsets(top: AppDelegate.statusHeight + 44.0, left: 0, bottom: 0, right: 0)
        tmp.isAlwaysBouncing = true
        return tmp
    }()
    
    private lazy var mList = UICollectionView(frame: self.bounds, collectionViewLayout: self.mLayout).apply({ [weak self] in
        $0.backgroundView  = UIView()
        $0.backgroundColor = .clear
        $0.dataSource = self
        $0.delegate = self
        WalletCell.register(in: $0)
        $0.contentInsetAdjustmentBehavior = .never
    })
    
    private var mWallets: [IWallet] = [IWallet]()
    var wallets: [IWallet] = [] {
        didSet {
            mWallets = wallets.reversed()
            mList.reloadData()
        }
    }
    
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
    
    private let mRefresh = UIRefreshControl()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(mList)
        addSubview(mBlur)
        mList.insertSubview(mRefresh, at: 0)
        mRefresh.addTarget(self, action: #selector(refresh), for: .valueChanged)
    }
    
    @objc private func refresh() {
        mRefresh.endRefreshing()
        mWallets.forEach({ $0.flushCache() })
        mList.reloadData()
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    func add(wallet: IWallet) {
        let completion = {
            AppDelegate.lock()
            self.mList.performBatchUpdates({
                self.mWallets.insert(wallet, at: 0)
                self.wallets.append(wallet)
                self.mList.insertItems(at: [IndexPath(item: 0, section: 0)])
            }, completion: { _ in
                AppDelegate.unlock()
                self.mList.setContentOffset(.zero, animated: true)
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
        AppDelegate.lock()
        mList.performBatchUpdates({
            var i = [IndexPath]()
            self.mWallets.enumerated().forEach({
                if wallet.privateKey == $0.element.privateKey {
                    i.append(IndexPath(item: $0.offset, section: 0))
                }
            })
            if i.count > 0 {
                self.mWallets.removeAll(where: { $0.address == wallet.address })
                self.wallets.removeAll(where: { $0.address == wallet.address })
                self.mList.deleteItems(at: i)
            }
        }, completion: { _ in
            AppDelegate.unlock()
        })
    }
    
    private var mOldFrame: CGRect = .zero
    
    private func showBlur() {
        guard let s = mSelected, let c = mList.cellForItem(at: s) as? WalletCell else { return }

        mOldFrame = convert(c.card.bounds, from: c.card)
        addSubview(c.card)
        c.card.frame = mOldFrame
        
        AppDelegate.lock()
        UIView.animate(withDuration: 0.35, animations: {
            self.mBlur.effect = UIBlurEffect(style: .dark)
            c.card.origin = CGPoint(x: (self.width - c.card.width)/2.0, y: (self.height - c.card.height)/2.0 - 100.scaled)
        }, completion: { _ in
            AppDelegate.unlock()
        })
    }
    
    private func hideBlur(s: IndexPath, c: WalletCell) -> UIViewPropertyAnimator {
        let anim = UIViewPropertyAnimator(duration: 0.35, curve: .easeInOut, animations: {
            c.card.frame = self.mOldFrame
            self.mBlur.effect = nil
        })
        anim.addCompletion({ p in
            if p == .end {
                c.card.frame = c.card.convert(c.card.bounds, to: c)
                c.addSubview(c.card)
            }
        })
        return anim
    }
    
    @discardableResult
    private func set(selected: IndexPath?) -> UIViewPropertyAnimator? {
        let anim: UIViewPropertyAnimator?
        if let s = selected {
            mSelected = s
            mList.isUserInteractionEnabled = false
            mActive = mWallets[s.row]
            anim = UIViewPropertyAnimator(duration: 0.35, curve: .easeInOut, animations: { [weak self] in
                self?.showFirst(s: s, wallet: self?.mActive)
            })
            anim?.addCompletion({ [weak self] _ in
                self?.showBlur()
            })
            addGestureRecognizer(mTap)
            addGestureRecognizer(mPan)
        } else if let s = mSelected, let c = mList.cellForItem(at: s) as? WalletCell {
            mActive = nil
            anim = hideBlur(s: s, c: c)
            anim?.addCompletion({ [weak self] _ in
                self?.afterBlur(s: s)
            })
            removeGestureRecognizer(mTap)
            removeGestureRecognizer(mPan)
        } else {
            anim = nil
        }

        if let a = anim {
            AppDelegate.lock()
            a.addCompletion({ _ in
                AppDelegate.unlock()
            })
            a.startAnimation()
        }
        return anim
    }
    
    private func afterBlur(s: IndexPath) {
        AppDelegate.lock()
        let anim = UIViewPropertyAnimator(duration: 0.35, curve: .easeInOut, animations: { [weak self] in
            self?.hideFirst(s: s)
        })
        anim.addCompletion({ _ in
            AppDelegate.unlock()
            self.mList.isUserInteractionEnabled = true
            self.mSelected = nil
        })
        anim.startAnimation()
    }

    private func hideFirst(s: IndexPath) {
        (mList.cellForItem(at: s) as? WalletCell)?.fullVisible = false
        mList.visibleCells.forEach({ cell in
            if let c = cell as? WalletCell {
                c.card.transform = .identity
            }
        })
        onActive(nil)
    }

    private func showFirst(s: IndexPath, wallet: IWallet?) {
        (mList.cellForItem(at: s) as? WalletCell)?.fullVisible = detailsForCard
        let shift = mLayout.itemSize.height - mLayout.topReveal
        mList.visibleCells.forEach({ cell in
            if let i = self.mList.indexPath(for: cell), i.item > s.item, let c = cell as? WalletCell {
                c.card.transform = CGAffineTransform(translationX: 0, y: shift)
            }
        })
        onActive(wallet)
    }

    @objc private func hideTapped() {
        set(selected: nil)
    }
    
    private var mCloseAnimation = false
    private var mAnimator = UIViewPropertyAnimator()
    private var mPrevLayout: UICollectionViewLayout?
    private var mActive: IWallet?
    
    @objc private func panned(_ s: UIPanGestureRecognizer) {
        guard let selected = mSelected else { return }
        guard let c = mList.cellForItem(at: selected) as? WalletCell else { return }
        
        let newFraction = s.translation(in: self).y / height
        switch s.state {
        case .began:
            mCloseAnimation = false
            mAnimator = hideBlur(s: selected, c: c)
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
            if mCloseAnimation {
                AppDelegate.lock()
                mAnimator.addCompletion { [weak self] (p) in
                    self?.afterBlur(s: selected)
                    AppDelegate.unlock()
                }
                removeGestureRecognizer(mPan)
                removeGestureRecognizer(mTap)
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        mList.frame = bounds
        mBlur.frame = bounds
        mRefresh.bounds = CGRect(x: 0, y: -(AppDelegate.statusHeight + 44), width: width, height: 60)
    }

    // MARK: - UICollectionViewDataSource methods
    // -------------------------------------------------------------------------
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mWallets.count
    }
    
    func collectionView(_ cv: UICollectionView, cellForItemAt p: IndexPath) -> UICollectionViewCell {
        let cell = WalletCell.get(from: cv, at: p)
        cell.wallet = mWallets[p.row]
        cell.onBackUp = { [weak self] w in
            self?.onBackUp(w)
        }
        cell.onDelete = { [weak self] w in
            self?.onDelete(w)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        set(selected: mSelected == nil ? indexPath : nil)
    }

}
