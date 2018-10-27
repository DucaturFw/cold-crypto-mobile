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
    var value: String = ""
    var data: String = "0x"
    
    required init() {}
    
    var amountFormatted: String {
        if let d = Wei(value), let eth = try? Converter.toEther(wei: d) {
            return "\(eth.description) FTM"
        }
        return "--"
    }
    
}
