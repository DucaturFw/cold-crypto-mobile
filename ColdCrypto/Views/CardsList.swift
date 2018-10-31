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
    
    private var mReversedWallets: [IWallet] = [IWallet]()
    var wallets: [IWallet] = [] {
        didSet {
            mReversedWallets = wallets.reversed()
            reloadData()
        }
    }
    
    private let mLayout: TGLStackedLayout = {
        let wid = UIScreen.main.bounds.width
        let tmp = TGLStackedLayout()
        tmp.itemSize  = CGSize(width: wid, height: wid / 270.0 * 160.0)
        tmp.topReveal = 87.scaled
        tmp.layoutMargin = UIEdgeInsetsMake(UIApplication.shared.statusBarFrame.height + 44.0, 0, 0, 0)
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
        contentInsetAdjustmentBehavior = .never
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    func add(wallet: IWallet) {
        set(selected: nil, completion: {
            UIApplication.shared.beginIgnoringInteractionEvents()
            self.performBatchUpdates({
                self.mReversedWallets.insert(wallet, at: 0)
                self.wallets.append(wallet)
                self.insertItems(at: [IndexPath(item: 0, section: 0)])
            }, completion: { _ in
                UIApplication.shared.endIgnoringInteractionEvents()
//                self.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: true)
                self.setContentOffset(.zero, animated: true)
            })
        })
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
    
    private func set(selected: IndexPath?, completion: @escaping ()->Void) {
        if let s = selected, let newLayout = TGLExposedLayout(exposedItemIndex: s.item) {
            mLayout.contentOffset = contentOffset;
            (cellForItem(at: s) as? WalletView)?.fullVisible = true
            newLayout.layoutMargin = mLayout.layoutMargin
            newLayout.itemSize = mLayout.itemSize
            newLayout.bottomPinningCount = 0
            newLayout.topPinningCount = 0
            UIApplication.shared.beginIgnoringInteractionEvents()
            setCollectionViewLayout(newLayout, animated: true, completion: { finished in
                self.mLayout.overwriteContentOffset = true
                UIApplication.shared.endIgnoringInteractionEvents()
                completion()
            })
        } else if let s = mSelected {
            (cellForItem(at: s) as? WalletView)?.fullVisible = false
            UIApplication.shared.beginIgnoringInteractionEvents()
            setCollectionViewLayout(mLayout, animated: true, completion: { finished in
                UIApplication.shared.endIgnoringInteractionEvents()
                self.mLayout.overwriteContentOffset = false
                completion()
            })
        } else {
            completion()
        }
        mSelected = selected
    }

    // MARK: - UICollectionViewDataSource methods
    // -------------------------------------------------------------------------
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return wallets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! WalletView
        cell.wallet = mReversedWallets[indexPath.row]
        cell.onBackUp = { [weak self] w in
            self?.onBackUp(w)
        }
        cell.onDelete = { [weak self] w in
            self?.set(selected: nil, completion: { [weak self] in
                self?.onDelete(w)
            })
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        set(selected: indexPath.item == mSelected?.item ? nil : indexPath, completion: {})
    }
    
}
