//
//  ETHToken.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 05/12/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import UIKit
import EthereumKit
import HandyJSON

class Token: HandyJSON {
    var name: String?
    var decimals: Int?
    var address: String?
    required init() {}
}

class ETHToken: IToken {
    var amount: Int64 = 0

    static let tokens: [ETHToken] = {
        if let path = Bundle.main.path(forResource: "ERCTokens", ofType: "json") {
            let tmp = try? String(contentsOfFile: path)
            let tokens = [Token].deserialize(from: tmp)
            return tokens?.compactMap({
                ETHToken(name: $0?.name ?? "",
                         token: ERC20(contractAddress: $0?.address ?? "", decimal: $0?.decimals ?? 0, symbol: $0?.name ?? ""))
            }) ?? []
        }
        return []
    }()

    static let formatter: NumberFormatter = {
        let tmp = NumberFormatter()
        tmp.decimalSeparator = "."
        tmp.maximumFractionDigits = 6
        tmp.minimumFractionDigits = 0
        tmp.minimumIntegerDigits  = 1
        return tmp
    }()
    
    static func token(transaction t: ETHTransaction) -> ETHToken? {
        return tokens.first(where: {
            let tmp = $0.token.contractAddress.lowercased()
            return t.to.lowercased() == tmp || t.from.lowercased() == tmp || t.contract.lowercased() == tmp
        })
    }
    
    private let mToken: ERC20
    private let mName: String
    
    var token: ERC20 {
        return mToken
    }

    init(token: TokenObj) {
        mToken = ERC20(contractAddress: token.address, decimal: token.decimal, symbol: token.name)
        mName = token.name
    }
    
    init(name: String, token: ERC20) {
        mToken = token
        mName = name
    }
    
    var decimal: Int {
        return mToken.decimal
    }
    
    var order: Int {
        return 0
    }
    
    var symbol: String {
        return mToken.symbol
    }
    
    var balance: String {
        return description(for: 0)
    }
    
    var text: String {
        return  "\(balance) \(mToken.symbol)"
    }
    
    var name: String {
        return mName
    }
    
    var value: String {
        return ""
    }
    
    var money: String {
        return ""
    }
    
    func description(for amount: BInt) -> String {
        return ETHToken.description(for: amount, decimal: mToken.decimal)
    }
    
    static func description(for amount: BInt, decimal: Int) -> String {
        return  "\(amount / (BInt(10)**decimal))"
    }
    
    func isValid(address: String) -> Bool {
        return EthereumAddress.isValid(address: address) != nil
    }
    
    func send(to: String, amount: Decimal, completion: @escaping (String?)->Void) {}
    
}
