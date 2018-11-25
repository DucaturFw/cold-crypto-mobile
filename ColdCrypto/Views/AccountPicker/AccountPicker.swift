//
//  AccountPicker.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 26/11/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import UIKit

class AccountPicker: UITableView, UITableViewDelegate, UITableViewDataSource {
    
    private let mAccounts: [String]
    
    var onPicked: (String)->Void = { _ in }
    
    init(accounts: [String]) {
        mAccounts = accounts
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: min(mAccounts.count, 5) * 50),
                   style: .plain)
        rowHeight = 50
        estimatedRowHeight = 0
        separatorStyle = .none
        delegate = self
        dataSource = self
        AccountCell.register(in: self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    // MARK:- UITableViewDelegate, UITableViewDataSource methods
    // -------------------------------------------------------------------------
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mAccounts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = AccountCell.get(from: tableView, at: indexPath)
        cell.textLabel?.text = mAccounts[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        onPicked(mAccounts[indexPath.row])
    }
    
}
