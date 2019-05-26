//
//  Blockchain.swift
//  MultiMask
//
//  Created by Kirill Kozhuhar on 05/10/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import UIKit

enum Blockchain : String, CaseIterable {

    class Network {

        enum ETH : String, INetwork, CaseIterable {
            case MainNet = "1"
            case RinkeBy = "4"
            
            var name: String {
                switch self {
                case .MainNet: return "MainNet"
                case .RinkeBy: return "RinkeBy"
                }
            }
            
            var value: String {
                return rawValue
            }
            
            var isTest: Bool {
                switch self {
                case .MainNet: return false
                case .RinkeBy: return true
                }
            }
            
            var node: String {
                switch self {
                case .MainNet: return "https://mainnet.infura.io/8d9fdb63b80048e5b31c5b8e2650434e"
                case .RinkeBy: return "https://rinkeby.infura.io/8d9fdb63b80048e5b31c5b8e2650434e"
                }
            }
            
            func url(tid: String) -> URL? {
                switch self {
                case .MainNet: return URL(string: "https://etherscan.io/tx/\(tid)")
                case .RinkeBy: return URL(string: "https://rinkeby.etherscan.io/tx/\(tid)")
                }
            }
            
        }
        
        enum EOS : String, INetwork, CaseIterable {
            case MainNet = "aca376f206b8fc25a6ed44dbdc66547c36c6c33e3a119ffbeaef943642f0e906"
            case Jungle  = "e70aaab8997e1dfce58fbfac80cbbb8fecec7b99cf982a9444273cbc64c41473"

            var name: String {
                switch self {
                case .MainNet: return "MainNet"
                case .Jungle:  return "Jungle"
                }
            }
            
            var value: String {
                return rawValue
            }
            
            var isTest: Bool {
                switch self {
                case .MainNet: return false
                case .Jungle: return true
                }
            }
            
            var node: String {
                switch self {
                case .MainNet: return "https://eos.greymass.com"
                case .Jungle:  return "https://jungle2.cryptolions.io:443"
                }
            }
            
            func url(tid: String) -> URL? {
                switch self {
                case .MainNet: return URL(string: "https://bloks.io/transaction/\(tid)")
                case .Jungle: return URL(string: "https://jungle.bloks.io/transaction/\(tid)")
                }
            }
        }
        
    }
    
    case ETH = "ETH"
    case EOS = "EOS"
    
    var networks: [INetwork] {
        switch self {
        case .ETH: return Network.ETH.allCases
        case .EOS: return Network.EOS.allCases
        }
    }
    
    func network(from: String?) -> INetwork? {
        guard let f = from else { return nil }
        switch self {
        case .ETH: return Network.ETH(rawValue: f)
        case .EOS: return Network.EOS(rawValue: f)
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
        case .ETH: return UIImage(named: "ethSmall") ?? UIImage()
        case .EOS: return UIImage(named: "eosSmall") ?? UIImage()
        }
    }
    
    func largeIcon() -> UIImage {
        switch self {
        case .ETH: return UIImage(named: "ethLarge") ?? UIImage()
        case .EOS: return UIImage(named: "eosLarge") ?? UIImage()
        }
    }
    
    func symbol() -> String {
        return rawValue
    }
    
    func getExchangeRate(completion: @escaping (Double?)->Void) {
        guard
            let url = URL(string: "https://min-api.cryptocompare.com/data/price?fsym=\(rawValue)&tsyms=USD,EUR")
            else { completion(nil); return }
        URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
            if (response as? HTTPURLResponse)?.statusCode == 200,
                let data = data,
                let tmp  = try? JSONSerialization.jsonObject(with: data, options: []),
                let obj  = tmp as? [String : Double] {
                DispatchQueue.main.async { completion(obj["USD"]) }
            } else {
                DispatchQueue.main.async { completion(nil) }
            }
            if let e = error {
                print("get exchange rate failed. reason \(e)")
            }
        }).resume()
    }
        
    
    func newWallet(seed: String, name: String?, data: String?, segwit: Bool?, network: INetwork) -> IWallet? {
        guard let data = data, data.count > 2 else { return nil }

        let nam = name ?? "\(self.name()) Wallet"
        let key = data.replacingCharacters(in: data.startIndex ..< data.index(data.startIndex, offsetBy: 2), with: "")
        if data.hasPrefix("00") { // private key
            switch self {
            case .ETH:  return ETHWallet(blockchain: self, network: network, name: nam, data: data, privateKey: key)
            case .EOS:  return EOSWallet(network: network, name: nam, data: data, privateKey: key)
            }
        } else if data.hasPrefix("01"), let phrase = String(data: Data(hex: key), encoding: .utf8) { // custom seed
            switch self {
            case .ETH:  return ETHWallet(blockchain: self, network: network, name: nam, data: data, index: 0, seed: phrase)
            case .EOS:  return EOSWallet(network: network, name: nam, data: data, seed: phrase, index: 0)
            }
        } else if data.hasPrefix("02") { // derived hd wallet
            guard let index = UInt32(key, radix: 16) else { return nil }
            switch self {
            case .ETH:  return ETHWallet(blockchain: self, network: network, name: nam, data: data, index: index, seed: seed)
            case .EOS:  return EOSWallet(network: network, name: nam, data: data, seed: seed, index: index)
            }
        } else {
            return nil
        }
    }

}
