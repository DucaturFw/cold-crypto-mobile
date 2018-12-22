//
//  SendVC.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 07/12/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import UIKit

class SendVC: AlertVC {
    
    init(wallet: IWallet, to: String) {
        let v = NewTransaction(parent: nil, wallet: wallet, to: to)
        super.init(nil, view: v, style: .sheet, arrow: true, withButtons: false)
        v.parent = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
}
