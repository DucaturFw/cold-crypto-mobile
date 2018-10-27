//
//  ApiPay.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 27/10/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import Foundation
import HandyJSON

class ApiPay: HandyJSON {
    
    var to: String = ""
    var gasPrice: String = ""
    var value: String = ""
    var data: String?
    var callback: String?
    var blockchain: String?
    
    required init() {}
    
}
