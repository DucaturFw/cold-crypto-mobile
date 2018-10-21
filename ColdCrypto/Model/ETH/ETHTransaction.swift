//
//  Transaction.swift
//  MultiMask
//
//  Created by Kirill Kozhuhar on 10/08/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import UIKit
import EthereumKit
import HandyJSON

class ETHTransaction : ITransaction, HandyJSON {
    
    var timestamp: String = ""
    var positive: Bool = false
    var hash: String = ""
    var from: String = ""
    var to: String = ""
    var val: String = ""
    var input: String = ""
    var contract: String = ""
    var tokenSymbol: String = ""
    var blockchain: Blockchain = .ETH
    
    private var mValue: String?
    private var mWhere: String?
    
    var order: Int {
        return Int(timestamp) ?? 0
    }
    
    init(hash: String, from: String, to: String, value: String, positive: Bool,
         timestamp: String, input: String, contract: String, token: String, blockchain: Blockchain) {
        self.input = input
        self.hash  = hash
        self.from  = from
        self.to  = to
        self.val = value
        self.positive  = positive
        self.timestamp = timestamp
        self.contract  = contract
        self.tokenSymbol = token
        self.blockchain = blockchain
    }
    
    required init() {}
    
    var text: String {
        if let time = TimeInterval(timestamp) {
            return Utils.formatter.string(from: Date(timeIntervalSince1970: time))
        }
        return "--"
    }
    
    var name: String {
        return mWhere ?? (positive ? from : to)
    }
    
    var money: String {
        return ""
    }
    
    var value: String {
        if let token = mValue {
            return token
        } else if let wei = Wei(val), let eth = try? Converter.toEther(wei: wei) {
            return "\(eth.description.trimmed) \(blockchain.symbol())"
        }
        return "--"
    }
    
    let icon: UIImage? = nil
    
}
