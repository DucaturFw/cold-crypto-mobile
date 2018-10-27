//
//  Net.swift
//  MultiMask
//
//  Created by Kirill Kozhuhar on 06/08/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import UIKit
import EthereumKit

extension String : Error {}

class ETHNet {

    static let UnknownWallet = "unknown wallet"
    
    private weak var mWallet: ETHWallet?
    private let mGeth: Geth
    
    init(wallet: ETHWallet) {
        mWallet = wallet
        mGeth = Geth(configuration: Configuration(
            network: wallet.network,
            nodeEndpoint: wallet.endpoint,
            etherscanAPIKey: "ZC66358FTE2I7NV3YNUVDE2Y4PI8BQKRNB",
            debugPrints: false
        ))
    }

    func getBalance(completion: @escaping (Balance?, Error?)->Void) {
        guard let w = mWallet else {
            completion(nil, ETHNet.UnknownWallet)
            return
        }
        mGeth.getBalance(of: w.address) { (result) in
            switch result {
            case .success(let b) : completion(b, nil)
            case .failure(let e) : completion(nil, e)
            }
        }
    }
    
    func getGasPrice(completion: @escaping (Wei?, Error?)->Void) {
        mGeth.getGasPrice { price in
            switch price {
            case .success(let p) : completion(p, nil)
            case .failure(let e) : completion(nil, e)
            }
        }
    }
    
    func getNonce(completion: @escaping (Int?, Error?)->Void) {
        guard let w = mWallet else {
            completion(nil, ETHNet.UnknownWallet)
            return
        }
        mGeth.getTransactionCount(of: w.address) { (result) in
            switch result {
            case .success(let n):
                completion(n, nil)
            case .failure(let e):
                completion(nil, e)
            }
        }
    }
    
    func send(value: Wei,
              to: String,
              gasPrice: Int,
              gasLimit: Int,
              data: Data, completion: @escaping (String?, Error?)->Void) {
        guard let w = mWallet else {
            completion(nil, ETHNet.UnknownWallet)
            return
        }
        getNonce(completion: { nonce, error in
            if let nonce = nonce {
                let t = RawTransaction(value: value, to: to, gasPrice: gasPrice, gasLimit: gasLimit, nonce: nonce, data: data)
                do {
                    let tx = try w.wallet.sign(rawTransaction: t)
                    self.mGeth.sendRawTransaction(rawTransaction: tx, completionHandler: { (result) in
                        switch result {
                        case .success(let s): completion(s.id, nil)
                        case .failure(let e): completion(nil, e)
                        }
                    })
                } catch let e {
                    completion(nil, e)
                }
            } else {
                completion(nil, error)
            }
        })
    }
    
    func getTokenHistory(completion: @escaping ([ETHTransaction]?, Error?)->Void) {
        guard let w = mWallet else {
            completion(nil, ETHNet.UnknownWallet)
            return
        }
        let own = w.address
        let chain = w.blockchain
        mGeth.getTokenTransactions(address: own) { result in
            switch result {
            case .success(let trans) :
                DispatchQueue.global().async {
                    var tmp: [ETHTransaction] = []
                    trans.elements.forEach({ (t) in
                        tmp.append(ETHTransaction(hash: t.hash,
                                                  from: t.from,
                                                  to: t.to,
                                                  value: t.value,
                                                  positive: own.lowercased() != t.from.lowercased(),
                                                  timestamp: t.timeStamp,
                                                  input: t.input,
                                                  contract: t.contractAddress,
                                                  token: t.tokenSymbol,
                                                  blockchain: chain))
                    })
                    DispatchQueue.main.async {
                        completion(tmp, nil)
                    }
                }
            case .failure(let error) :
                completion(nil, error)
            }
        }
    }
    
    func getHistory(completion: @escaping ([ETHTransaction]?, Error?)->Void) {
        guard let w = mWallet else {
            completion(nil, ETHNet.UnknownWallet)
            return
        }
        let own = w.address
        let chain = w.blockchain
        mGeth.getTransactions(address: own) { (result) in
            switch result {
            case .success(let trans):
                DispatchQueue.global().async {
                    var tmp: [ETHTransaction] = []
                    trans.elements.forEach({
                        tmp.append(ETHTransaction(hash: $0.hash,
                                               from: $0.from,
                                               to: $0.to,
                                               value: $0.value,
                                               positive: own.lowercased() != $0.from.lowercased(),
                                               timestamp: $0.timeStamp,
                                               input: $0.input,
                                               contract: $0.contractAddress,
                                               token: "",
                                               blockchain: chain))
                    })
                    tmp.sort(by: { (one, two) -> Bool in
                        (Int(one.timestamp) ?? 0) > (Int(two.timestamp) ?? 0)
                    })
                    completion(tmp, nil)
                }
            case .failure(let error):
                completion(nil, error)
            }
        }
    }
    
    func sendTokens(to: String, amount: String, token: ERC20, gasPrice: Wei, completion: @escaping (String?, Error?)->Void) {
        guard let w = mWallet else {
            completion(nil, ETHNet.UnknownWallet)
            return
        }
        do {
            let p = Int(gasPrice.description)
            let data = try token.generateDataParameter(toAddress: to, amount: amount)
            
            let doit: (Wei)->Void = { gas in
                self.getNonce { nonce, error in
                    if let n = nonce, let p = Int(gasPrice.description), let g = Int(gas.description) {
                        do {
                            let rawTransaction = RawTransaction(wei: "0",
                                                                to: token.contractAddress,
                                                                gasPrice: p+1,
                                                                gasLimit: g,
                                                                nonce: n,
                                                                data: data)
                            let tx = try w.wallet.sign(rawTransaction: rawTransaction)
                            self.mGeth.sendRawTransaction(rawTransaction: tx) { result in
                                switch result {
                                case .success(let s): completion(s.id, nil)
                                case .failure(let e): completion(nil, e)
                                }
                            }
                        } catch let e {
                            completion(nil, e)
                        }
                    } else {
                        completion(nil, error)
                    }
                }
            }
            mGeth.getEstimateGas(from: w.address,
                                 to: token.contractAddress,
                                 gasPrice: p,
                                 value: 0,
                                 data: "0x\(data.toHexString())") { (result) in
                                    switch result {
                                    case .success(let w) : doit(w)
                                    case .failure(let e) : completion(nil, e)
                                    }
            }
        } catch let e {
            completion(nil, e)
        }
    }
    
}
