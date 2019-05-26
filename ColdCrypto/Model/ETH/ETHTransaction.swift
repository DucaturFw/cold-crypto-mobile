//
//  Transaction.swift
//  MultiMask
//
//  Created by Kirill Kozhuhar on 10/08/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import UIKit
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
    let network: INetwork
    
    private var mValue: String?
    private var mWhere: String?
    
    var order: Int {
        return Int(timestamp) ?? 0
    }
    
    init(hash: String, from: String, to: String, value: String, positive: Bool,
         timestamp: String, input: String, contract: String, token: String,
         blockchain: Blockchain, network: INetwork) {
        self.network = network
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
        
        if let t = ETHToken.token(transaction: self) {
            mValue = t.symbol
            var gg = input

            if gg.starts(with: "0x") {
                let range = gg.startIndex...gg.index(gg.startIndex, offsetBy: 1)
                gg.replaceSubrange(range, with: "")
                
                let nameRange = gg.startIndex...gg.index(gg.startIndex, offsetBy: 7)
                gg.replaceSubrange(nameRange, with: "")
                
                let paramRange = gg.startIndex...gg.index(gg.startIndex, offsetBy: 63)
                mWhere = String(gg[paramRange])
                mWhere?.removingRegexMatches(pattern: "^0+", replaceWith: "")
                if let x = mWhere {
                    mWhere?.insert(contentsOf: "0x", at: x.startIndex)
                }
                
                gg.replaceSubrange(paramRange, with: "")
                gg.removingRegexMatches(pattern: "^0+", replaceWith: "")

                if let amount = BInt(gg, radix: 16) {
                    mValue = "\(t.description(for: amount).trimmed) \(t.symbol)"
                }
            }
        }
    }
    
    required init() {
        network = Blockchain.Network.ETH.RinkeBy
    }
    
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
        let sign = positive ? "+" : "-"
        if let token = mValue {
            return sign + token
        } else if tokenSymbol.count > 0, let wei = BInt(val) {
            return "\(sign)\(ETHToken.description(for: wei, decimal: 18).trimmed) \(tokenSymbol)"
        } else if let wei = Wei(val), let eth = try? Converter.toEther(wei: wei) {
            return "\(sign)\(eth.description.trimmed) \(blockchain.symbol())"
        }
        return "--"
    }
    
    let icon: UIImage? = nil
    
    var url: URL? {
        return network.url(tid: hash)
    }
    
}
