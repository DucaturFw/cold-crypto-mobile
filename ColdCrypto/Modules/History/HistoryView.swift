//
//  HistoryView.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 05/12/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import Foundation

class HistoryView: UITableView, IWalletDelegate, UITableViewDelegate,
UITableViewDataSource, HistoryCellDelegate {

    var onRefreshed: ()->Void = {}
    
    private let mWallet: IWallet
    
    private var mItems: [ITransaction] = []
    
    private let mEmpty = UIImageView(image: UIImage(named: "noTrans")).apply({
        $0.transform = CGAffineTransform(scaleX: 1.scaledRaw, y: 1.scaledRaw)
        $0.alpha = 0
    })
    
    private var mSelected: IndexPath?
    
    private lazy var mPull = UIRefreshControl().apply({ [weak self] in
        $0.addTarget(self, action: #selector(refresh), for: .valueChanged)
    })
    
    private var mTokens = TokenList(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 80))

    init(frame: CGRect, wallet: IWallet, padding: CGFloat) {
        mWallet = wallet
        super.init(frame: frame, style: .plain)
        rowHeight = 68.scaled
        estimatedRowHeight = 0
        separatorStyle = .none
        delegate = self
        dataSource = self
        contentInset.bottom = padding
        contentInset.top = 0
        HistoryCell.register(in: self)
        insertSubview(mEmpty, at: 0)
        insertSubview(mPull, at: 0)
        mTokens.tint = CardProvider.getTint(wallet.address)
        mTokens.isUserInteractionEnabled = false
        mTokens.onToken = { token in
            SendTokens(token: token, wallet: wallet).show()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(coinsSent(_:)), name: .coinsSent, object: nil)
        pull(animated: false, hud: mPull)
        wallet.delegate = self
        wallet.getHistory(force: false)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    @objc private func coinsSent(_ n: Any?) {
        guard let id = ((n as? Notification)?.object as? String) else { return }
        if id == mWallet.id {
            refresh()
        }
    }

    @objc private func refresh() {
        mWallet.getHistory(force: true)
        onRefreshed()
    }
    
    // MARK:- IWalletDelegate methods
    // -------------------------------------------------------------------------
    func on(history: [ITransaction], of sender: IWallet) {
        if sender.id == mWallet.id {
            mItems = history
            reloadData()
            mPull.endRefreshing()
            UIView.animate(withDuration: 0.25, animations: {
                self.mEmpty.alpha = self.mItems.count == 0 ? 1.0 : 0.0
            })
        }
    }
    
    func on(tokens: [TokenObj]) {
        mTokens.update(tokens: tokens)
        mTokens.isUserInteractionEnabled = tokens.count > 0

        if tokens.count > 0 && tableHeaderView == nil {
            tableHeaderView = mTokens
        } else if tokens.count == 0 && tableHeaderView != nil {
            panGestureRecognizer.isEnabled = false
            panGestureRecognizer.isEnabled = true
            
            UIView.animate(withDuration: 0.25, animations: {
                self.mTokens.alpha = 0.0
            }, completion: { _ in
                self.mTokens.alpha = 1.0
                UIView.animate(withDuration: 0.25, animations: {
                    self.tableHeaderView = nil
                })
            })
        }
    }
    
    // MARK:- UITableViewDelegate, UITableViewDataSource methods
    // -------------------------------------------------------------------------
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        mEmpty.center = CGPoint(x: width/2.0, y: height * 0.44 + scrollView.contentOffset.y)
        if (scrollView.isTracking || scrollView.isDragging) && mSelected != nil {
            mSelected = nil
            beginUpdates()
            endUpdates()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mItems.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return HistoryCell.defHeight + (indexPath == mSelected ? HistoryDetails.defHeight : 0.0)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = HistoryCell.get(from: self, at: indexPath)
        cell.transaction = mItems[indexPath.row]
        cell.delegate = self
        return cell
    }
    
    // MARK:- HistoryCellDelegate methods
    // -------------------------------------------------------------------------
    func onSelected(cell: HistoryCell) {
        let i = indexPath(for: cell)
        mSelected = i == mSelected ? nil : i
        beginUpdates()
        endUpdates()
        if let i = mSelected {
            scrollToRow(at: i, at: .top, animated: true)
            let view = HistoryDetails(frame: CGRect(x: 0, y: 0, width: width, height: HistoryDetails.defHeight))
            view.transaction = cell.transaction
            view.alpha = 0.0
            cell.bottomView = view
            AppDelegate.lock()
            UIView.animate(withDuration: 0.25, animations: {
                view.alpha = 1.0
            }) { (_) in
                AppDelegate.unlock()
            }
        } else {
            AppDelegate.lock()
            UIView.animate(withDuration: 0.25, animations: {
                cell.bottomView?.alpha = 0.0
            }) { (_) in
                cell.bottomView = nil
                AppDelegate.unlock()
            }
        }
    }
    
}
