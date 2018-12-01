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
    var address: String { get }
    var index: UInt32 { get }
    var data: String { get }
    var name: String { get }
    var seed: String? { get }
    
    func sign(transaction: ApiParamsTx, wallet: ApiParamsWallet, completion: @escaping (String?)->Void)
    func pay(to: ApiParamsTx, completion: @escaping (String?)->Void)
    func parseContract(contract: ApiSignContractCall) -> IContract?
    func getBalance(completion: @escaping (String?, String?)->Void)
    func getAmount(tx: ApiParamsTx) -> String
    func getTo(tx: ApiParamsTx) -> String

}
