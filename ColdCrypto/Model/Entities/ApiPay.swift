//
//  ApiPay.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 27/10/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import Foundation
import HandyJSON
import EthereumKit

class ApiPay: HandyJSON {
    
    var to: String = ""
    var gasPrice: String = ""
    var value: String = ""
    var data: String?
    var callback: String?
    var blockchain: String?
    
    var amountFormatted: String {
        if let d = Wei(value), let eth = try? Converter.toEther(wei: d) {
            return "\(eth.description) FTM"
        }
        return "--"
    }
    
    required init() {}
    
}
