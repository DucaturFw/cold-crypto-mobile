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
    
    private struct Keys {
        static let chain   = "blockchain"
        static let name    = "name"
        static let data    = "data"
        static let segwit  = "segwit"
        static let network = "network"
        static let seed    = "seed"
        static let wallets = "wallets"
        static let index   = "index"
        
        private init() {}
    }
    
    var wallets: [IWallet] = []
    var seed: String  = ""
    var index: UInt32 = 0
    
    static func new(name: String, segwit: Bool) -> Profile? {
        let p = Profile()
        p.seed = Mnemonic.create(strength: .normal, language: .english).joined(separator: " ")
        return p
    }
    
    init() {}
    
    init?(json: Dictionary<String, Any>?) {
        guard let dict = json else { return nil }
        guard let seed = (dict[Keys.seed] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines) else { return nil }
        let words = seed.split(separator: " ").count
        guard words == 12 || words == 24 else { return nil }

        for w in (dict[Keys.wallets] as? [[String: Any]]) ?? [] {
            guard let id = w[Keys.chain] as? String, let b = Blockchain(rawValue: id) else { continue }
            guard let network = b.network(from: w[Keys.network] as? String) else { continue }
            guard let wallet  = b.newWallet(seed: seed,
                                            name: w[Keys.name] as? String,
                                            data: w[Keys.data] as? String,
                                            segwit: w[Keys.segwit] as? Bool,
                                            network: network) else { continue }
            wallets.append(wallet)
        }
        
        self.seed  = seed
        self.index = (dict[Keys.index] as? UInt32) ?? 0
    }
    
    func getJson() -> Dictionary<String, Any> {
        var gg = Array<Dictionary<String, Any>>()
        for w in wallets {
            gg.append([
                Keys.name    : w.name,
                Keys.data    : w.data,
                Keys.chain   : w.blockchain.rawValue,
                Keys.network : w.chain,
                Keys.segwit  : false])
        }
        return [
            Keys.index:   index,
            Keys.seed:    seed,
            Keys.wallets: gg
        ]
    }
    
    func newWallet(chain: Blockchain, name: String, data: String, segwit: Bool) -> IWallet? {
//        guard let current = chains.first(where: { $0.id == chain }) else { return nil }
//        guard let wallet  = chain.newWallet(seed: seed, name: name, data: data, segwit: segwit, time: Date().timeIntervalSince1970) else { return nil }
//        current.wallets.append(wallet)
//        return wallet
        return nil
    }
    
    func addWallet(wallet: IWallet) {
        wallets.insert(wallet, at: 0)
    }
    
}
