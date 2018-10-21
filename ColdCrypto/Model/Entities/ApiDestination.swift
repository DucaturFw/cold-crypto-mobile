//
//  ApiDestination.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 20/10/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import Foundation
import HandyJSON

class ApiDestination: HandyJSON {
 
    var to: String = ""
    var nonce: Int = 0
    var gasPrice: String = ""
    var value: String = ""
    
    required init() {}
    
}
