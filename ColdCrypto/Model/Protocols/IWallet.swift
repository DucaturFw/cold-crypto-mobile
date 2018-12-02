//
//  IWallet.swift
//  MultiMask
//
//  Created by Kirill Kozhuhar on 07/10/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import Foundation

enum ConnectionState {
    case start, stop, success
}

protocol IWallet : class {
    
    var blockchain: Blockchain { get }
    var privateKey: String { get }
    var address: String { get }
    var index: UInt32 { get }
    var data: String { get }
    var name: String { get }
    var seed: String? { get }
    var id: String { get }
    var time: TimeInterval { get }
    var connectionStatus: ConnectionState { get set }
    var onConnected: ((ConnectionState)->Void)? { get set }
    
    func sign(transaction: ApiParamsTx, wallet: ApiParamsWallet, completion: @escaping (String?)->Void)
    func pay(to: ApiParamsTx, completion: @escaping (String?)->Void)
    func parseContract(contract: ApiSignContractCall) -> IContract?
    func getBalance(completion: @escaping (String?, String?)->Void)
    func getAmount(tx: ApiParamsTx) -> String
    func getTo(tx: ApiParamsTx) -> String
    func flushCache()

}
