//
//  IWallet.swift
//  MultiMask
//
//  Created by Kirill Kozhuhar on 07/10/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import Foundation

protocol IWallet : class {
    
    var blockchain: Blockchain { get }
    var privateKey: String { get }
    var exchange: Double { get }
    var address: String { get }
    var index: UInt32 { get }
    var data: String { get }
    var name: String { get }
    var seed: String? { get }
    
    func getTransaction(to: ApiParamsTx, with: ApiParamsWallet) -> String?
    func pay(to: ApiPay, completion: @escaping (String?)->Void)
    func getBalance(completion: @escaping (String?)->Void)
    
}