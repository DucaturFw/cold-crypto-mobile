//
//  SendTokens.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 03/03/2019.
//  Copyright © 2019 Kirill Kozhuhar. All rights reserved.
//

import UIKit

class SendTokens: AlertVC {
    
    private let mSend: NewTokenTransaction
    
    init(token: TokenObj?, wallet: IWallet) {
        mSend = NewTokenTransaction(token: token, parent: nil, wallet: wallet)
        super.init(nil, view: mSend, style: .sheet, arrow: true, withButtons: false, draggable: true)
        mSend.parent = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
}
