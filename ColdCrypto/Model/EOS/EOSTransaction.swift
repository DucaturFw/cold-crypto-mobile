//
//  EOSTransaction.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 05/12/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import Foundation
import HandyJSON

class EOSTransaction: ITransaction {
    
    var blockchain: Blockchain = .EOS
    var name: String = ""
    var money: String = ""
    var icon: UIImage? = nil
    var order: Int = 0
    
    var tokenSymbol: String
    var positive: Bool
    var text: String
    var hash: String
    var from: String
    var val: String
    var to: String
    
    init(account: String, source: EOSActions.Data) {
        let tmp = (source.quantity ?? "0.0000 EOS").split(separator: " ")
        
        val = (tmp.count > 1 ? String(tmp[0]) : "0").trimmed
        hash = source.id ?? ""
        tokenSymbol = (tmp.count > 1 ? String(tmp[1]) : "")

        positive = account != source.from
        from = source.from ?? ""
        to   = source.to ?? ""
        name = positive ? from : to
        
        if let t = source.time, let date = Utils.EOSformatter.date(from: t) {
            text = Utils.formatter.string(from: date)
        } else {
            text = "--"
        }
    }
    
    init(account: String, source: EOSTransactionRaw) {
        val = source.quantity.trimmed
        hash = source.hash
        tokenSymbol = source.symbol
        positive = source.direction.lowercased() == "in"
        if positive {
            from = source.another_account
            to   = account
            name = from
        } else {
            from = account
            to   = source.another_account
            name = to
        }
        
        if let date = Utils.EOSformatter.date(from: source.trx_timestamp) {
            text = Utils.formatter.string(from: date)
        } else {
            text = "--"
        }
    }
    
    var value: String {
        let sign = positive ? "+" : "-"
        return "\(sign)\(val) \(tokenSymbol)"
    }
    
}
