//
//  ApiJoin.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 25/10/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import Foundation
import HandyJSON

class ApiJoin : HandyJSON, ApiMessage {

    static var method: String {
        return "join"
    }
    static var id: Int {
        return 1
    }
    
    var sid: String? = nil
    
    required init() {}
    
    init(sid: String) {
        self.sid = sid
    }
    
    var params: String {
        return toJSONString() ?? "{}"
    }
    
}
