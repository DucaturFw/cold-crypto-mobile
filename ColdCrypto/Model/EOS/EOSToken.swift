//
//  EOSToken.swift
//  MultiMask
//
//  Created by Kirill Kozhuhar on 17/11/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import Foundation

class EOSToken {

    var text: String {
        return "\(balance) \(symbol)"
    }
    
    var name: String {
        return symbol
    }
    
    var order: Int {
        return 0
    }
    
    var decimal: Int = 4
    
    var balance: String {
        return inEOS.compactValue ?? "--"
    }
    
    var symbol: String = ""
    
    var amount: Int64
    
    var inEOS: Decimal {
        return Decimal(amount) / 10_000
    }
    
    private weak var mWallet: EOSWallet?

    init(wallet: EOSWallet, balance: EOSBalance) {
        mWallet = wallet
        let parts = balance.balance.split(separator: " ")
        
        if let a = Decimal(string: String(parts.first ?? "")) {
            amount = NSDecimalNumber(decimal: a * 10_000).int64Value
        } else {
            amount = 0
        }
        
        symbol = String(parts.last ?? "")
    }
    
}
