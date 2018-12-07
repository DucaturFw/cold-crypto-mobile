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

    weak var delegate: IWalletDelegate?
    
    var blockchain: Blockchain = .EOS
    var privateKey: String
    var address: String
    var index: UInt32 = 0
    var data: String
    var name: String
    var id: String
    private(set) var time: TimeInterval

    var onConnected: ((ConnectionState)->Void)?
    var connectionStatus: ConnectionState = .stop {
        didSet {
            onConnected?(connectionStatus)
        }
    }
    
    var isFeeSupport: Bool {
        return false
    }
    
    private var cachedTrans: [ITransaction] = []
    private var cachedRate: Double?
    private var cachedAmount: Decimal?
    private var cachedBalance: String?
    private let mPKObject: PrivateKey
   
    init?(name: String, data: String, privateKey: String, time: TimeInterval) {
        guard let pk = try? PrivateKey(keyString: privateKey),
            let pk2 = pk else {
                return nil
        }
        self.privateKey = pk2.rawPrivateKey()
        self.address = name
        self.name = name
        self.data = data
        self.time = time
        mPKObject = pk2
        id = UUID().uuidString
    }
    
    init?(name: String, data: String, seed: String, index: UInt32, time: TimeInterval) {
        guard let pk = try? PrivateKey(mnemonicString: seed, index: index),
            let pk2 = pk else {
                return nil
        }
        self.privateKey = pk2.rawPrivateKey()
        self.address = name
        self.seed = seed
        self.name = name
        self.data = data
        self.time = time
        mPKObject = pk2
        id = UUID().uuidString
    }

    func flushCache() {
        cachedRate = nil
        cachedBalance = nil
    }
    
    func getBalance(completion: @escaping (String?, String?) -> Void) {
        if let b = cachedBalance, let r = cachedRate, let a = cachedAmount {
            completion(b, (a * Decimal(r)).money)
            return
        }
        
        let group = Group(2) { [weak self] in
            completion(self?.cachedBalance, doit { [weak self] in
                guard let r = self?.cachedRate, let a = self?.cachedAmount else { return nil }
                return (a * Decimal(r)).money
            })
        }
        EOSRPC.sharedInstance.getTableRows(scope: name,
                                           code: "eosio.token",
                                           table: "accounts",
                                           completion: { [weak self] (r: TableRowResponse<EOSBalance>?, e: Error?) in
                                            if let s = self {
                                                let tokens = r?.rows?.compactMap({ EOSToken(wallet: s, balance: $0) })
                                                if let c = tokens?.first(where: { $0.symbol == s.blockchain.symbol() }) {
                                                    s.cachedAmount = c.inEOS
                                                    s.cachedBalance = c.inEOS.compactValue
                                                }
                                            }
                                            group.done()
        })
        
        blockchain.getExchangeRate { [weak self] (rate) in
            if let r = rate {
                self?.cachedRate = r
            }
            group.done()
        }
    }
    
    func sign(transaction: ApiParamsTx, wallet: ApiParamsWallet, completion: @escaping (String?)->Void) {
        let method  = transaction.method ?? ""
        let chainId = wallet.chainId
        let pk = privateKey
        let tx = transaction.transaction?.toJSONString() ?? "{}"

        let gg = EOSUtils.call(js: "script.pack({method:\"\(method)\", chainId: \"\(chainId)\", privateKey: \"\(pk)\", transaction: \(tx)})", result: { tx in
            DispatchQueue.main.async {
                completion(tx?.count == 0 || tx == "" || tx == "null" ? nil : tx)
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
        return tx.transaction?.actions?.first?.data?["quantity"] as? String ?? "--"
    }
    
    func getTo(tx: ApiParamsTx) -> String {
        return tx.transaction?.actions?.first?.data?["to"] as? String ?? "--"
    }
    
    func parseContract(contract: ApiSignContractCall) -> IContract? {
        return EOSContract(contract: contract)
    }
    
    func getHistory(force: Bool) {
        if force {
            cachedTrans = []
        }
        if cachedTrans.count > 0 {
            delegate?.on(history: cachedTrans, of: self)
            return
        }
        EOSUtils.getTransactions2(account: name, completion: { [weak self] trans in
            if let s = self, let t = trans {
                s.cachedTrans = t
                s.delegate?.on(history: s.cachedTrans, of: s)
            }
        })
    }
    
    func isValid(address: String?) -> String? {
        guard let a = address?.lowercased(), a.count == 12 else { return nil }
        do {
            let regex = try NSRegularExpression(pattern: "^[a-z1-5]{12}$", options: [])
            let match = regex.firstMatch(in: a, options: [], range: NSRange(location: 0, length: a.count))
            guard let range = match?.range else { return nil }
            return (range.location == 0 && range.length == 12) ? a : nil
        } catch {
            return nil
        }
    }
    
    func getFee(completion: @escaping (String?) -> Void) {
        completion(nil)
    }
    
    private func send(value: Decimal, to: String, symbol: String, completion: @escaping (String?) -> Void) {
        guard
            let pk = try? PrivateKey(keyString: privateKey),
            let pk2 = pk,
            let amount = value.EOSCompactValue
            else {
                completion(nil)
                return
        }
        
        let transfer = Transfer()
        transfer.from = name
        transfer.to = to
        transfer.quantity = "\(amount) \(symbol)"
        transfer.memo = "ColdCrypto"
        
        Currency.transferCurrency(transfer: transfer, code: "eosio.token", privateKey: pk2, completion: { (result, error) in
            completion(result?.transactionId)
        })
    }
    
    func send(value: Decimal, to: String, completion: @escaping (String?) -> Void) {
        send(value: value, to: to, symbol: blockchain.symbol(), completion: completion)
    }
    
}
