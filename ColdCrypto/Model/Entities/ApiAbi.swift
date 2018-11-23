//
//  ApiAbi.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 21/11/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import Foundation
import HandyJSON

class ApiAbi: HandyJSON {
    
    var method: String?
    var args: [String]?
    
    required init() {}
    
}
