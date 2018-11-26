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
    
    func sign(transaction: ApiParamsTx, wallet: ApiParamsWallet, completion: @escaping (String?)->Void) {
        let method  = transaction.method ?? ""
        let chainId = wallet.chainId
        let pk = privateKey
        let tx = transaction.transaction?.toJSONString() ?? "{}"

        let gg = EOSUtils.call(js: "script.pack({method:\"\(method)\", chainId: \"\(chainId)\", privateKey: \"\(pk)\", transaction: \(tx)})", result: { tx in
            DispatchQueue.main.async {
                completion(tx)
            }
        })

        if gg?.isBoolean == true && gg?.toBool() != true {
            DispatchQueue.main.async {
                completion(nil)
            }
        }
    }
    
    func pay(to: ApiParamsTx, completion: @escaping (String?) -> Void) {
        let transfer = Transfer()
        transfer.from = name
        transfer.to = to.to
        transfer.quantity = to.value
        transfer.memo = "ColdCrypto"
        Currency.transferCurrency(transfer: transfer, code: "eosio.token", privateKey: mPKObject, completion: { (result, error) in
            completion(result?.transactionId)
        })
    }
    
    func getAmount(tx: ApiParamsTx) -> String {
        return tx.transaction?.actions?.first?.data?["quantity"] ?? "--"
    }
    
    func getTo(tx: ApiParamsTx) -> String {
        return tx.transaction?.actions?.first?.data?["to"] ?? "--"
    }
    
}