//
//  Contract.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 21/11/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import Foundation
import HandyJSON

class ContractImpl: HandyJSON {
    
    class Param: HandyJSON {
        
        var name:  String?
        var value: AnyObject?
        var type:  String?
        
        required init() {}
        
    }
    
    var name: String?
    var params: [Param]?
    
    required init() {}
    
}
