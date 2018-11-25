//
//  EOSWallet.swift
//  MultiMask
//
//  Created by Kirill Kozhuhar on 16/11/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import UIKit

class EOSWallet: IWallet {
    
    var seed: String?

    var blockchain: Blockchain = .EOS
    var privateKey: String
    var address: String
    var index: UInt32 = 0
    var data: String
    var name: String
    
    private var cachedBalance: String?
    private let mPKObject: PrivateKey
    
    init?(name: String, data: String, privateKey: String) {
        guard let pk = try? PrivateKey(keyString: privateKey),
            let pk2 = pk else {
                return nil
        }
        self.privateKey = pk2.rawPrivateKey()
        self.address = name
        self.name = name
        self.data = data
        mPKObject = pk2
    }
    
    init?(name: String, data: String, seed: String, index: UInt32) {
        guard let pk = try? PrivateKey(mnemonicString: seed, index: index),
            let pk2 = pk else {
                return nil
        }
        self.privateKey = pk2.rawPrivateKey()
        self.address = name
        self.seed = seed
        self.name = name
        self.data = data
        mPKObject = pk2
    }

    func getBalance(completion: @escaping (String?) -> Void) {
        if let b = cachedBalance {
            completion(b)
            return
        }
        EOSRPC.sharedInstance.getTableRows(scope: name,
                                           code: "eosio.token",
                                           table: "accounts",
                                           completion: { [weak self] (r: TableRowResponse<EOSBalance>?, e: Error?) in
                                            if let s = self {
                                                let tokens = r?.rows?.compactMap({ EOSToken(wallet: s, balance: $0) })
                                                if let c = tokens?.first(where: { $0.symbol == s.blockchain.symbol() }) {
                                                    s.cachedBalance = c.inEOS.compactValue?.trimmed
                                                }
                                            }
                                            completion(self?.cachedBalance)
        })
    }
    
    func getTransaction(to: ApiParamsTx, with: ApiParamsWallet) -> String? {
        return nil
    }
    
    func pay(to: ApiPay, completion: @escaping (String?) -> Void) {
        
    }
    
}
