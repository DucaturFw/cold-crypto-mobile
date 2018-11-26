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

    private var mBalance: String?
    private var mSeed: String?
    private lazy var mNet = ETHNet(wallet: self)

    let network = Network.private(chainID: 4, testUse: true)
    let wallet: Wallet
    var gasLimit: Int = 21000
    var gasPrice: Wei?
    
    convenience init?(blockchain: Blockchain, name: String, data: String, index: UInt32, seed: String) {
        guard let s = try? Mnemonic.createSeed(mnemonic: seed.split(separator: " ").map({ String($0) })) else { return nil }
        self.init(blockchain: blockchain, name: name, data: data, index: index, seed: s)
    }
    
    init?(blockchain: Blockchain, name: String, data: String, privateKey: String) {
        self.name  = name
        self.data  = data
        self.index = 0
        self.mSeed = nil
        self.wallet   = Wallet(network: network, privateKey: privateKey, debugPrints: false)
        self.address  = self.wallet.address().lowercased()
        self.blockchain = blockchain
    }
    
    init?(blockchain: Blockchain, name: String, data: String, index: UInt32, seed: Data) {
        guard let w = try? Wallet(seed: seed, index: index, network: ETHWallet.network, debugPrints: false) else { return nil }
        self.name  = name
        self.data  = data
        self.index = index
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

    func getBalance(completion: @escaping (String?)->Void) {
        if let b = mBalance {
            completion(b)
        } else {
            mNet.getBalance { [weak self] (b, e) in
                self?.mBalance = (try? b?.ether())??.compactValue?.trimmed
                DispatchQueue.main.async {
                    completion(self?.mBalance)
                }
            }
        }
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
    
}
