//
//  Blockchain.swift
//  MultiMask
//
//  Created by Kirill Kozhuhar on 05/10/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import EthereumKit
import UIKit

enum Blockchain : String, CaseIterable {
    
    case ETH = "ETH"
    case EOS = "EOS"
    
    var chainId: String {
        switch self {
        case .ETH: return "4"
        case .EOS: return "e70aaab8997e1dfce58fbfac80cbbb8fecec7b99cf982a9444273cbc64c41473"
        }
    }
    
    func name() -> String {
        switch self {
        case .ETH: return "etherium".loc
        case .EOS: return "eos".loc
        }
    }
    
    func icon() -> UIImage {
        switch self {
        case .ETH: return UIImage(named: "eth2") ?? UIImage()
        case .EOS: return UIImage(named: "eosCoin") ?? UIImage()
        }
    }
    
    func symbol() -> String {
        return rawValue
    }
    
    func newWallet(seed: String, name: String?, data: String?, segwit: Bool?) -> IWallet? {
        guard let data = data, data.count > 2 else { return nil }
        
        let nam = name ?? "\(self.name()) Wallet"
        let key = data.replacingCharacters(in: data.startIndex ..< data.index(data.startIndex, offsetBy: 2), with: "")
        if data.hasPrefix("00") { // private key
            switch self {
            case .ETH:  return ETHWallet(blockchain: self, name: nam, data: data, privateKey: key)
            case .EOS:  return EOSWallet(name: nam, data: data, privateKey: key)
            }
        } else if data.hasPrefix("01"), let phrase = String(data: Data(hex: key), encoding: .utf8) { // custom seed
            switch self {
            case .ETH:  return ETHWallet(blockchain: self, name: nam, data: data, index: 0, seed: phrase)
                case .EOS:  return EOSWallet(name: nam, data: data, seed: phrase, index: 0)
            }
        } else if data.hasPrefix("02") { // derived hd wallet
            guard let index = UInt32(key, radix: 16) else { return nil }
            switch self {
            case .ETH:  return ETHWallet(blockchain: self, name: nam, data: data, index: index, seed: seed)
            case .EOS:  return EOSWallet(name: nam, data: data, seed: seed, index: index)
            }
        } else {
            return nil
        }
    }

}
