//
//  Signer.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 24/10/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import Foundation

protocol Signer: class {
    @discardableResult
    func getWalletList(json: String, id: Int, completion: @escaping (String)->Void) -> Bool
    
    @discardableResult
    func signTransferTx(json: String, id: Int, completion: @escaping (String)->Void) -> Bool
    
    @discardableResult
    func parse(request: String, supportRTC: Bool, block: @escaping (String)->Void) -> Bool
}
