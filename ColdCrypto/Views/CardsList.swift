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
    
    var onActive: (IWallet?)->Void = { _ in }
    
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
    
    var wallets: [IWallet] = [] {
        didSet {
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
        mList.insertSubview(mRefresh, at: 0)
        mRefresh.addTarget(self, action: #selector(refresh), for: .valueChanged)
    }
    
    @objc private func refresh() {
        mRefresh.endRefreshing()
        wallets.forEach({ $0.flushCache() })
        mList.reloadData()
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    func add(wallet: IWallet) {
        let completion = {
            AppDelegate.lock()
            self.mList.performBatchUpdates({
                self.wallets.insert(wallet, at: 0)
                self.mList.insertItems(at: [IndexPath(item: 0, section: 0)])
            }, completion: { _ in
                AppDelegate.unlock()
                self.mList.setContentOffset(.zero, animated: true)
                self.mList.reloadData()
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
            self.wallets.enumerated().forEach({
                if wallet.id == $0.element.id {
                    i.append(IndexPath(item: $0.offset, section: 0))
                }
            })
            if i.count > 0 {
                self.wallets.removeAll(where: { $0.id == wallet.id })
                self.mList.deleteItems(at: i)
            }
        }, completion: { _ in
            AppDelegate.unlock()
        })
    }
    
    private var mHistory: HistoryView?
    
    private func show(index: IndexPath) -> UIViewPropertyAnimator {
        let top  = CGFloat(AppDelegate.statusHeight + 30.scaled)
        let pad  = WalletCell.cardSize(width: width).height - WalletCell.padding
        let view = HistoryView(frame: CGRect(x: 0, y: top + pad, width: width, height: height - top - pad),
                               wallet: wallets[index.item],
                               padding: Style.Dims.bottomScan + AppDelegate.bottomGap)
        view.alpha = 0
        insertSubview(view, at: 0)
        mHistory = view
        return UIViewPropertyAnimator(duration: 0.35, curve: .easeInOut, animations: {
            (self.mList.cellForItem(at: index) as? WalletCell)?.fullVisible = self.detailsForCard
            self.mList.visibleCells.forEach({ cell in
                if let c = cell as? WalletCell {
                    let y = c.card.convert(.zero, to: self).y
                    let s = doit {
                        if let i = self.mList.indexPath(for: cell), i.item == index.item {
                            return top - y
                        } else {
                            return self.height - y
                        }
                        } as CGFloat
                    c.card.transform = CGAffineTransform(translationX: 0, y: s)
                }
            })
            self.mActive = self.wallets[index.row]
            self.onActive(self.mActive)
            self.mHistory?.alpha = 1.0
        })
    }
    
    private func hide(index: IndexPath) -> UIViewPropertyAnimator {
        let cell = (self.mList.cellForItem(at: index) as? WalletCell)
        let anim = UIViewPropertyAnimator(duration: 0.35, curve: .easeInOut, animations: {
            self.mHistory?.alpha = 0
            cell?.fullVisible = false
            self.mList.visibleCells.forEach({ cell in
                (cell as? WalletCell)?.card.transform = .identity
            })
            self.onActive(nil)
        })
        anim.addCompletion({ p in
            if p == .end {
                self.mHistory?.removeFromSuperview()
                self.mHistory = nil
                self.mList.isUserInteractionEnabled = true
                self.mSelected = nil
                self.mActive = nil
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
            anim = show(index: s)
            addGestureRecognizer(mTap)
            addGestureRecognizer(mPan)
        } else if let s = mSelected {
            anim = hide(index: s)
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

    @objc private func hideTapped() {
        set(selected: nil)
    }
    
    private var mCloseAnimation = false
    private var mAnimator = UIViewPropertyAnimator()
    private var mPrevLayout: UICollectionViewLayout?
    private var mActive: IWallet?
    
    @objc private func panned(_ s: UIPanGestureRecognizer) {
        guard let selected = mSelected else { return }
        
        let newFraction = s.translation(in: self).y / height
        switch s.state {
        case .began:
            mCloseAnimation = false
            mAnimator = hide(index: selected)
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
                mAnimator.addCompletion { (p) in
                    AppDelegate.unlock()
                }
                removeGestureRecognizer(mPan)
                removeGestureRecognizer(mTap)
            } else {
                mAnimator.addCompletion { (p) in
                    self.onActive(self.mActive)
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        mList.frame = bounds
        mRefresh.bounds = CGRect(x: 0, y: -(AppDelegate.statusHeight + 44), width: width, height: 60)
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
        let cell = WalletCell.get(from: cv, at: p)
        cell.wallet = wallets[p.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        set(selected: mSelected == nil ? indexPath : nil)
    }

}
