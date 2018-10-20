//
//  Profile.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 20/10/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import UIKit
import EthereumKit

class Profile {
    
    var id: String = ""
    var seed: String = ""
    var version: String = ""
    var chains: [Chain] = []
    
    static func new(name: String, segwit: Bool) -> Profile? {
        let s = Mnemonic.create(strength: .normal, language: .english)
        let p = Profile()
        p.seed = s.joined(separator: " ")
        Blockchain.allCases.forEach({
            if let eth = Chain.new(blockchain: $0, seed: p.seed, name: name, segwit: segwit) {
                p.chains.append(eth)
            }
        })
        return p
    }
    
    init() {}
    
    init?(json: Dictionary<String, Any>?) {
        guard let dict = json else { return nil }
        guard let id = (dict["id"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines) else { return nil }
        guard let seed = (dict["seed"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines), seed.split(separator: " ").count == 12 else { return nil }
        guard let version = (dict["version"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines) else { return nil }
        guard let dicts = dict["chains"] as? [[String: Any]] else { return nil }
        
        let tempChains = Chain.from(seed: seed, dictionary: dicts)
        if (tempChains.count == 0) { return nil }
        
        self.id = id
        self.seed = seed
        self.chains = tempChains
        self.version = version
    }
    
    func getJson() -> Dictionary<String, Any> {
        var gg = Array<Dictionary<String, Any>>()
        chains.forEach({
            gg.append($0.getJson())
        })
        return [
            "id": id,
            "seed": seed,
            "version": version,
            "chains" : gg
        ]
    }
    
    func newWallet(chain: Blockchain, name: String, data: String, segwit: Bool) -> IWallet? {
        guard let current = chains.first(where: { $0.id == chain }) else { return nil }
        guard let wallet  = chain.newWallet(seed: seed, name: name, data: data, segwit: segwit) else { return nil }
        current.wallets.append(wallet)
        return wallet
    }
    
    func chainOrCreate(blockchain: Blockchain) -> Chain {
        guard let chain = chains.first(where: { $0.id == blockchain }) else {
            let tmp = Chain(blockchain: blockchain)
            chains.append(tmp)
            return tmp
        }
        return chain
    }
    
}
