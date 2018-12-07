//
//  HistoryView.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 05/12/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import Foundation

class HistoryView: UITableView, IWalletDelegate, UITableViewDelegate, UITableViewDataSource {

    private let mWallet: IWallet
    
    private var mItems: [ITransaction] = []
    
    private let mEmpty = UIImageView(image: UIImage(named: "noTrans")).apply({
        $0.transform = CGAffineTransform(scaleX: 1.scaledRaw, y: 1.scaledRaw)
        $0.alpha = 0
    })
    
    private lazy var mPull = UIRefreshControl().apply({ [weak self] in
        $0.addTarget(self, action: #selector(refresh), for: .valueChanged)
    })
    
    init(frame: CGRect, wallet: IWallet, padding: CGFloat) {
        mWallet = wallet
        super.init(frame: frame, style: .plain)
        rowHeight = 68.scaled
        estimatedRowHeight = 0
        separatorStyle = .none
        delegate = self
        dataSource = self
        contentInset.top = 20.scaled
        contentInset.bottom = padding
        HistoryCell.register(in: self)
        insertSubview(mPull, at: 0)
        pull(animated: false, hud: mPull)
        wallet.delegate = self
        wallet.getHistory(force: false)
        insertSubview(mEmpty, at: 0)
        NotificationCenter.default.addObserver(self, selector: #selector(coinsSent(_:)), name: .coinsSent, object: nil)
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
    
    // MARK:- UITableViewDelegate, UITableViewDataSource methods
    // -------------------------------------------------------------------------
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        mEmpty.center = CGPoint(x: width/2.0, y: height * 0.44 + scrollView.contentOffset.y)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = HistoryCell.get(from: self, at: indexPath)
        cell.transaction = mItems[indexPath.row]
        return cell
    }
    
}
