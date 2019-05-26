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
    var chain: String
    var data: String
    var name: String
    var id: String

    var canSendToken: Bool {
        return false
    }
    
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
    private let mPKObject: PrivateKey2
    private let mNetwork: INetwork
   
    var networkInfo: INetwork {
        return mNetwork
    }
    
    init?(network: INetwork, name: String, data: String, privateKey: String) {
        guard let pk = try? PrivateKey2(keyString: privateKey),
            let pk2 = pk else {
                return nil
        }
        self.privateKey = pk2.rawPrivateKey()
        self.address = name
        self.chain = network.value
        self.name = name
        self.data = data
        mPKObject = pk2
        mNetwork = network
        id = UUID().uuidString
    }
    
    init?(network: INetwork, name: String, data: String, seed: String, index: UInt32) {
        guard let pk = try? PrivateKey2(mnemonicString: seed, index: index),
            let pk2 = pk else {
                return nil
        }
        self.privateKey = pk2.rawPrivateKey()
        self.address = name
        self.chain = network.value
        self.seed = seed
        self.name = name
        self.data = data
        mPKObject = pk2
        mNetwork = network
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
        EOSRPC.endpoint = mNetwork.node
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
        EOSRPC.endpoint = mNetwork.node
        Currency.transferCurrency(transfer: transfer, code: "eosio.token", privateKey: mPKObject, completion: { (result, error) in
            completion(result?.transactionId)
        })
    }
    
    func getAmount(tx: ApiParamsTx) -> String {
        return tx.transaction?.actions?.first?.data?["quantity"] as? String ?? "--"
    }
    
    func getTo(tx: ApiParamsTx) -> String {
        return isValid(address: tx.transaction?.actions?.first?.data?["to"] as? String) ?? "--"
    }
    
    func parseContract(contract: ApiSignContractCall) -> IContract? {
        return EOSContract(contract: contract)
    }
    
    private var mCachedTokens: [TokenObj]?
    
    func getHistory(force: Bool) {
        if force {
            cachedTrans = []
            mCachedTokens = nil
        }
        if cachedTrans.count > 0 {
            delegate?.on(history: cachedTrans, of: self)
        } else {
            EOSRPC.endpoint = mNetwork.node
            EOSUtils.getTransactions2(network: mNetwork, account: name, completion: { [weak self] trans in
                if let s = self {
                    if let t = trans {
                        s.cachedTrans = t
                    }
                    s.delegate?.on(history: s.cachedTrans, of: s)
                }
            })
        }
        
        if let c = mCachedTokens {
            delegate?.on(tokens: c)
        } else {
            getTokensList(completion: { [weak self] tokens in
                if let t = tokens {
                    self?.mCachedTokens = t
                }
                self?.delegate?.on(tokens: self?.mCachedTokens ?? [])
            })
        }
    }
    
    private func getTokensList(completion: @escaping ([TokenObj]?)->Void) {
        let deliver: ([TokenObj]?)->Void = { tokens in
            DispatchQueue.main.async {
                completion(tokens)
            }
        }
        
        guard let url = URL(string: "https://api.eospark.com/api?module=account&action=get_token_list&apikey=a9564ebc3289b7a14551baf8ad5ec60a&account=\(address)") else {
            deliver([])
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            guard let d = data else {
                deliver(nil)
                return
            }
            DispatchQueue.global().async {
                do {
                    let h = try JSONDecoder().decode(TokenHistoryEOS.self, from: d)
                    deliver(h.data?.symbol_list?.compactMap({
                        if let b = $0.balance, let bd = Decimal(string: b), let c = $0.code, let s = $0.symbol {
                            return TokenObj(name: s, amount: bd, address: c, decimal: 4)
                        }
                        return nil
                    }))
                } catch let e {
                    print("\(e)")
                    deliver(nil)
                }
            }
        }).resume()
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
    
    func sendTokens(to: String, amount: Decimal, token: TokenObj, completion: @escaping (String?) -> Void) {
        send(value: amount, to: to, symbol: token.name, token: token.address, completion: completion)
    }
    
    private func send(value: Decimal, to: String, symbol: String, token: String = "eosio.token", completion: @escaping (String?) -> Void) {
        guard
            let pk = try? PrivateKey2(keyString: privateKey),
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
        
        EOSRPC.endpoint = mNetwork.node
        Currency.transferCurrency(transfer: transfer, code: token, privateKey: pk2, completion: { (result, error) in
            completion(result?.transactionId)
        })
    }
    
    func send(value: Decimal, to: String, completion: @escaping (String?) -> Void) {
        send(value: value, to: to, symbol: blockchain.symbol(), completion: completion)
    }
    
    static func getAccounts(pub: String, network: INetwork, completion: @escaping ([String]?, String?) -> ()) {
        do {
            EOSRPC.endpoint = network.node
            let parts = pub.split(separator: " ")
            let pk = parts.count == 1 ? try PrivateKey2(keyString: pub) : try PrivateKey2(mnemonicString: pub, index: 0)
            guard let pk2 = pk else { throw "Invalid private key" }
            EOSRPC.sharedInstance.getKeyAccounts(pub: PublicKey2(privateKey: pk2).rawPublicKey(), completion: { r, e in
                completion(r?.accountNames, pk2.rawPrivateKey())
            })
        } catch let e {
            print("getAccounts -> \(e)")
            completion(nil, nil)
        }
    }
    
}
