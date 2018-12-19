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
    
    let net: INetwork

    let network: Network
    let wallet: Wallet
    var gasLimit: Int = 21000
    var gasPrice: Wei?
    
    convenience init?(blockchain: Blockchain, network: INetwork, name: String, data: String, index: UInt32, seed: String) {
        guard let s = try? Mnemonic.createSeed(mnemonic: seed.split(separator: " ").map({ String($0) })) else { return nil }
        self.init(blockchain: blockchain, network: network, name: name, data: data, index: index, seed: s)
    }
    
    init?(blockchain: Blockchain, network: INetwork, name: String, data: String, privateKey: String) {
        guard let chainId = Int(network.value) else { return nil }
        self.network = Network.private(chainID: chainId, testUse: chainId == 1)
        self.net   = network
        self.chain = network.value
        self.name  = name
        self.data  = data
        self.index = 0
        self.mSeed = nil
        self.id    = UUID().uuidString
        self.wallet   = Wallet(network: self.network, privateKey: privateKey, debugPrints: false)
        self.address  = self.wallet.address().lowercased()
        self.blockchain = blockchain
    }
    
    init?(blockchain: Blockchain, network: INetwork, name: String, data: String, index: UInt32, seed: Data) {
        guard let chainId = Int(network.value) else { return nil }
        self.network = Network.private(chainID: chainId, testUse: chainId == 1)
        
        guard let w = try? Wallet(seed: seed, index: index, network: self.network, debugPrints: false) else { return nil }
        
        self.net   = network
        self.chain = network.value
        self.name  = name
        self.data  = data
        self.index = index
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
        mBalance     = nil
        mCachedRate  = nil
        mCachedETH   = nil
        mCachedTrans = nil
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
    
    var chain: String
    
    var index: UInt32
    
    var id: String

    weak var delegate: IWalletDelegate?
    
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
    
    var onConnected: ((ConnectionState)->Void)?
    var connectionStatus: ConnectionState = .stop {
        didSet {
            onConnected?(connectionStatus)
        }
    }
    
    func getTokens(completion: @escaping ([ITransaction]?)->Void) {
        mNet.getTokenHistory { (trans, error) in
            completion(trans)
            if let e = error {
                print("get tokens failed. reason \(e)")
            }
        }
    }
    
    private func getTransactions(completion: @escaping ([ITransaction]?)->Void) {
        mNet.getHistory { (items, e) in
            completion(items)
            if let e = e {
                print("get transactions failed. reason \(e)")
            }
        }
    }
    
    private var mCachedTrans: [ITransaction]?
    
    func getHistory(force: Bool) {
        if force {
            mCachedTrans = nil
        }
        if let h = mCachedTrans {
            delegate?.on(history: h, of: self)
            return
        }
        
        var newItems = [ITransaction]()
        let group = Group(2) { [weak self] in
            DispatchQueue.global().async { [weak self] in
                newItems.sort { (one, two) -> Bool in
                    one.order > two.order
                }
                DispatchQueue.main.async { [weak self] in
                    self?.mCachedTrans = newItems
                    if let s = self {
                        s.delegate?.on(history: newItems, of: s)
                    }
                }
            }
        }

        let queue = DispatchQueue(label: "merge")
        getTransactions(completion: { items in
            queue.async {
                newItems.append(contentsOf: items ?? [])
                group.done()
            }
        })
        getTokens { [weak self] trans in
            let tkns = ETHToken.tokens(wallet: self)
            var fast = Dictionary<String, IToken>()
            tkns.forEach({ fast[$0.symbol] = $0 })
            trans?.forEach({ (t) in
                if let amount = Int64(t.val) {
                    fast[t.tokenSymbol]?.amount += (t.positive ? amount : -amount)
                }
            })
            queue.async {
                newItems.append(contentsOf: trans ?? [])
                group.done()
            }
        }
    }
    
    var isFeeSupport: Bool {
        return true
    }
    
    func isValid(address: String?) -> String? {
        guard let a1 = address else { return nil }
        return EthereumAddress.isValid(address: a1)
    }
    
    func getFee(completion: @escaping (String?)->Void) {
        let symbol = blockchain.symbol()
        getGasPrice(completion: { p in
            if let w = p, let eth = try? Converter.toEther(wei: w) {
                let price = eth * 21000
                if price > 0.00001 {
                    completion("\(price) \(symbol)")
                } else {
                    completion("\(price * 1000000000) GWei")
                }
            } else {
                completion(nil)
            }
        })
    }
    
    private func getGasPrice(completion: ((Wei?)->Void)? = nil) {
        mNet.getGasPrice { [weak self] price, error in
            self?.gasPrice = price
            completion?(price)
        }
    }
    
    func send(value: Decimal, to: String, completion: @escaping (String?)->Void) {
        guard let wei = try? Converter.toWei(ether: value) else {
            completion(nil)
            return
        }

        let lim: Int
        if let pp = gasPrice?.description, let i = Int(pp) {
            lim = i
        } else {
            lim = Converter.toWei(GWei: 10)
        }
        mNet.send(value: wei, to: to, gasPrice: lim, gasLimit: gasLimit, data: Data()) { (hash, error) in
            completion(hash)
        }
    }
    
}
