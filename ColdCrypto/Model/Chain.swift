//
//  Chain.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 20/10/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import Foundation
import EthereumKit

class Chain {
    
    var id: Blockchain
    var wallets: [IWallet] = []
    
    init(blockchain: Blockchain) {
        self.id = blockchain
    }
    
    static func from(seed: String, dictionary: [[String: Any]]) -> [Chain] {
        var chains = Array<Chain>()
        dictionary.forEach({ i in
            if let id = i["id"] as? String, let b = Blockchain(rawValue: id) {
                let chain = Chain(blockchain: b)
                if let wallets = i["wallets"] as? [[String: Any]] {
                    wallets.forEach({ w in
                        if let wallet = chain.id.newWallet(seed: seed, name: w["name"] as? String,
                                                           data: w["data"] as? String,
                                                           segwit: w["segwit"] as? Bool) {
                            chain.wallets.append(wallet)
                        }
                    })
                }
                if chain.wallets.count > 0 {
                    chains.append(chain)
                }
            }
        })
        return chains
    }
    
    static func new(blockchain: Blockchain, seed: String, name: String, segwit: Bool) -> Chain? {
        let chain = Chain(blockchain: blockchain)
        if let w = blockchain.newWallet(seed: seed, name: name, data: "0200", segwit: segwit) {
            chain.wallets.append(w)
            return chain
        }
        return nil
    }
    
    func getJson() -> [String: Any] {
        var gg = Array<Dictionary<String, Any>>()
        wallets.forEach({
            gg.append(["name": $0.name, "data": $0.data])
        })
        return ["id": id.rawValue, "wallets": gg]
    }
    
}
