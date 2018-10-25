//
//  ApiBlockchain.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 20/10/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import HandyJSON

class ApiParamsWallet: HandyJSON {
    
    var blockchain: String = ""
    var address: String = ""
    var chainId: Int = 0
    
    init(b: String, a: String, c: Int) {
        blockchain = b
        address = a
        chainId = c
    }
    
    required init() {}
    
}
