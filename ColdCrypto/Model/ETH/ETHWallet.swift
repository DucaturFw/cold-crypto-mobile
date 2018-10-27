//
//  Wallet.swift
//  MultiMask
//
//  Created by Kirill Kozhuhar on 04/08/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import HandyJSON
import Foundation
import EthereumKit
import Alamofire

extension Blockchain {
    func ethConfig() -> ETHWallet.Config? {
        switch self {
        case .ETH: return ETHWallet.Config(n: Network.private(chainID: 4, testUse: true), e: "https://rinkeby.infura.io/8d9fdb63b80048e5b31c5b8e2650434e")
        }
    }
}

class ETHWallet : IWallet {

    class Config {
        let network: Network
        let endpoint: String
        init(n: Network, e: String) {
            network  = n
            endpoint = e
        }
    }

    private var cachedGraph: [Decimal]?
    private var cachedMax: Decimal?
    private var cachedMin: Decimal?
    private var cachedRate: Double?
    private var cachedBalance: Wei?
    private var cachedIncome:  [IViewable]?
    private var cachedOutcome: [IViewable]?
    
    var isSupportTokens: Bool {
        return true
    }
    
    var network:  Network
    let wallet:   Wallet
    let endpoint: String
    
    var gasLimit: Int = 21000
    var gasPrice: Wei?
    
    convenience init?(blockchain: Blockchain, name: String, data: String, index: UInt32, seed: String) {
        guard let s = try? Mnemonic.createSeed(mnemonic: seed.split(separator: " ").map({ String($0) })) else { return nil }
        self.init(blockchain: blockchain, name: name, data: data, index: index, seed: s)
    }
    
    init?(blockchain: Blockchain, name: String, data: String, privateKey: String) {
        guard let n = blockchain.ethConfig() else { return nil }
        self.name  = name
        self.data  = data
        self.index = 0
        self.endpoint = n.endpoint
        self.network  = n.network
        self.wallet   = Wallet(network: network, privateKey: privateKey, debugPrints: false)
        self.address  = self.wallet.address().lowercased()
        self.blockchain = blockchain
    }
    
    init?(blockchain: Blockchain, name: String, data: String, index: UInt32, seed: Data) {
        guard let n = blockchain.ethConfig() else { return nil }
        guard let w = try? Wallet(seed: seed, index: index, network: n.network, debugPrints: false) else { return nil }
        self.name  = name
        self.data  = data
        self.index = index
        self.endpoint = n.endpoint
        self.network  = n.network
        self.wallet   = w
        self.address  = w.address().lowercased()
        self.blockchain = blockchain
    }

    // MARK:- IWallet methods
    // -------------------------------------------------------------------------
    func getTransaction(to: ApiParamsTx, with: ApiParamsWallet) -> String? {
        guard let v = Wei(to.value) else { return nil }
        guard let p = Int(to.gasPrice) else { return nil }
        let n = Network.private(chainID: with.chainId, testUse: true)
        let w = Wallet(network: n, privateKey: wallet.privateKey().toHexString(), debugPrints: false)
        let dd = to.data ?? "0x"
        let d = dd.starts(with: "0x") ? Data(hex: dd) : Data()
        let t = RawTransaction(value: v, to: to.to, gasPrice: p, gasLimit: gasLimit, nonce: to.nonce, data: d)
        return try? w.sign(rawTransaction: t)
    }
    
    func pay(to: ApiPay, completion: @escaping (String?)->Void) {
        guard let v = Wei(to.value), let p = Int(to.gasPrice) else {
            completion(nil)
            return
        }
        
        let dd = to.data ?? "0x"
        let d = dd.starts(with: "0x") ? Data(hex: dd) : Data()
        ETHNet(wallet: self).send(value: v, to: to.to, gasPrice: p, gasLimit: 100000, data: d, completion: { tx, error in
            completion(tx)
        })
    }
    
    var data: String
    
    var segwit: Bool {
        return false
    }
    
    var blockchain: Blockchain
    
    var address: String
    
    var name: String
    
    var index: UInt32
    
    var balance: Decimal? {
        guard let b = cachedBalance else { return nil }
        return try? Converter.toEther(wei: b)
    }
    
    var exchange: Double {
        return cachedRate ?? 0.0
    }
    
}
