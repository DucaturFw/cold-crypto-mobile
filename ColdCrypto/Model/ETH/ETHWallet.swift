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

class ETHWallet : IWallet {
    
    private static var network = Network.private(chainID: 4, testUse: true)
    
    class Config {
        let network: Network
        let endpoint: String
        init(n: Network, e: String) {
            network  = n
            endpoint = e
        }
    }

    private var mCachedETH: Decimal?
    private var mCachedRate: Double?
    private var mBalance: String?
    private var mSeed: String?
    private lazy var mNet = ETHNet(wallet: self)

    let network = Network.private(chainID: 4, testUse: true)
    let wallet: Wallet
    var gasLimit: Int = 21000
    var gasPrice: Wei?
    
    convenience init?(blockchain: Blockchain, name: String, data: String, index: UInt32, seed: String, time: TimeInterval) {
        guard let s = try? Mnemonic.createSeed(mnemonic: seed.split(separator: " ").map({ String($0) })) else { return nil }
        self.init(blockchain: blockchain, name: name, data: data, index: index, seed: s, time: time)
    }
    
    init?(blockchain: Blockchain, name: String, data: String, privateKey: String, time: TimeInterval) {
        self.name  = name
        self.data  = data
        self.index = 0
        self.mSeed = nil
        self.time  = time
        self.id    = UUID().uuidString
        self.wallet   = Wallet(network: network, privateKey: privateKey, debugPrints: false)
        self.address  = self.wallet.address().lowercased()
        self.blockchain = blockchain
    }
    
    init?(blockchain: Blockchain, name: String, data: String, index: UInt32, seed: Data, time: TimeInterval) {
        guard let w = try? Wallet(seed: seed, index: index, network: ETHWallet.network, debugPrints: false) else { return nil }
        self.name  = name
        self.data  = data
        self.index = index
        self.time  = time
        self.id    = UUID().uuidString
        self.mSeed = String(data: seed, encoding: .utf8)
        self.wallet   = w
        self.address  = w.address().lowercased()
        self.blockchain = blockchain
    }

    // MARK:- IWallet methods
    // -------------------------------------------------------------------------
    func sign(transaction: ApiParamsTx, wallet w: ApiParamsWallet, completion: @escaping (String?)->Void) {
        guard let v = Wei(transaction.value) else { completion(nil); return }
        guard let p = Int(transaction.gasPrice) else { completion(nil); return }
        guard let c = Int(w.chainId) else { completion(nil); return }
        let n = Network.private(chainID: c, testUse: true)
        let w = Wallet(network: n, privateKey: wallet.privateKey().toHexString(), debugPrints: false)
        let dd = transaction.data ?? "0x"
        let d = dd.starts(with: "0x") ? Data(hex: dd) : Data()
        let l = transaction.gasLimit ?? gasLimit
        let t = RawTransaction(value: v, to: transaction.to, gasPrice: p, gasLimit: l, nonce: transaction.nonce, data: d)
        
        if let tx = try? w.sign(rawTransaction: t) {
            completion("\"\(tx)\"")
        } else {
            completion(nil)
        }
    }
    
    func flushCache() {
        mBalance = nil
    }

    func getBalance(completion: @escaping (String?, String?)->Void) {
        if let b = mBalance, let r = mCachedRate, let e = mCachedETH {
            completion(b, (e*Decimal(r)).money)
            return
        }

        let group = Group(2) { [weak self] in
            completion(self?.mBalance, doit { [weak self] in
                guard let r = self?.mCachedRate, let e = self?.mCachedETH else { return nil }
                return (e*Decimal(r)).money
            })
        }
        mNet.getBalance { [weak self] (b, e) in
            if let eth = (try? b?.ether()) {
                self?.mCachedETH = eth
                self?.mBalance = self?.mCachedETH?.compactValue
            }
            group.done()
        }
        
        blockchain.getExchangeRate(completion: { [weak self] rate in
            if let r = rate {
                self?.mCachedRate = r
            }
            group.done()
        })
        
    }
    
    func pay(to: ApiParamsTx, completion: @escaping (String?)->Void) {
        guard let v = Wei(to.value), let p = Int(to.gasPrice) else {
            completion(nil)
            return
        }
        let dd = to.data ?? "0x"
        let d  = dd.starts(with: "0x") ? Data(hex: dd) : Data()
        mNet.send(value: v, to: to.to, gasPrice: p, gasLimit: 100000, data: d, completion: { tx, error in
            completion(tx)
        })
    }
    
    var data: String
    
    var blockchain: Blockchain
    
    var address: String
    
    var name: String
    
    var index: UInt32
    
    var id: String
    
    private(set) var time: TimeInterval

    var privateKey: String {
        return wallet.privateKey().toHexString()
    }
    
    var seed: String? {
        return mSeed
    }
    
    func getAmount(tx: ApiParamsTx) -> String {
        if let d = Wei(tx.value), let eth = try? Converter.toEther(wei: d) {
            return "\(eth.description) \(blockchain.symbol())"
        }
        return "--"
    }
    
    func getTo(tx: ApiParamsTx) -> String {
        return tx.to
    }
    
    func parseContract(contract: ApiSignContractCall) -> IContract? {
        return ETHContract(contract: contract)
    }
    
}
