//
//  ETHToken.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 05/12/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import UIKit
import EthereumKit

class ETHToken: IToken {
    
    static func tokens(wallet: ETHWallet?) -> [ETHToken] {
        return [
            ETHToken(icon: UIImage(named: "eos"),
                     name: "EOS",
                     token: ERC20(contractAddress: "0x8b2a7160bf12560f4e2f059fb40a7351ab5142a4", decimal: 18, symbol: "EOS"),
                     wallet: wallet),
            ETHToken(icon: UIImage(named: "snt"),
                     name: "StatusNetwork",
                     token: ERC20(contractAddress: "0xa17fafbab3a66262509c27bf4430bb4ec86af33a", decimal: 4, symbol: "SNT"),
                     wallet: wallet),
            ETHToken(icon: UIImage(named: "omg"),
                     name: "OmiseGO",
                     token: ERC20(contractAddress: "0x4133bc0d26756ca12eb06d2dc7cfbdac2d9595fb", decimal: 4, symbol: "OMG"),
                     wallet: wallet)
        ]
    }
    
    static let formatter: NumberFormatter = {
        let tmp = NumberFormatter()
        tmp.decimalSeparator = "."
        tmp.maximumFractionDigits = 6
        tmp.minimumFractionDigits = 0
        tmp.minimumIntegerDigits  = 1
        return tmp
    }()
    
    private static let cache = tokens(wallet: nil)
    
    static func token(transaction t: ETHTransaction) -> ETHToken? {
        return cache.first(where: {
            let tmp = $0.token.contractAddress.lowercased()
            return t.to.lowercased() == tmp || t.from.lowercased() == tmp || t.contract.lowercased() == tmp
        })
    }
    
    private let mToken: ERC20
    private let mName: String
    
    var token: ERC20 {
        return mToken
    }
    
    var amount: Int64 = 0
    
    var icon: UIImage?
    
    private weak var mWallet: ETHWallet? = nil
    
    init(icon: UIImage?, name: String, token: ERC20, wallet: ETHWallet?) {
        self.icon = icon
        mWallet = wallet
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
        return description(for: amount)
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
    
    func description(for amount: Int64) -> String {
        return ETHToken.description(for: amount, decimal: mToken.decimal)
    }
    
    static func description(for amount: Int64, decimal: Int) -> String {
        if let bb = Decimal(string: amount.description),
            let gg = Decimal(string: (BInt(10)**decimal).description),
            let hh = ETHToken.formatter.string(for: bb / gg) {
            return  hh
        }
        return  "\(BInt(amount) / (BInt(10)**decimal))"
    }
    
    func isValid(address: String) -> Bool {
        return EthereumAddress.isValid(address: address) != nil
    }
    
    func send(to: String, amount: Decimal, completion: @escaping (String?)->Void) {
//        mWallet?.sendTokens(to: to, amount: amount.description, token: mToken, completion: completion)
    }
    
}
