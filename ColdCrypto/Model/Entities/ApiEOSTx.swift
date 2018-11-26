//
//  ApiEOSTx.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 26/11/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import HandyJSON

class ApiEOSTx: HandyJSON {
    
    class Authorization: HandyJSON {
        var actor: String?
        var permission: String?
        required init() {}
    }
    
    class Action: HandyJSON {
        
        var account: String?
        var name: String?
        var authorization: [Authorization]?
        var data: [String: AnyObject]?
        required init() {}
        
    }
    
    var expiration: String?
    var ref_block_num: UInt64?
    var ref_block_prefix: UInt64?
    var actions: [Action]?
    
    required init() {}
    
}
