//
//  ApiParamsTx.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 20/10/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import EthereumKit
import Foundation
import HandyJSON

class ApiParamsTx: HandyJSON {
 
    var to: String = ""
    var nonce: Int = 0
    var gasPrice: String = ""
    var gasLimit: Int?
    var value: String = ""
    var data: String?
    var method: String?
    var transaction: ApiEOSTx?
    var callback: String?
    var blockchain: String?
    
    required init() {}
    
}
