//
//  ApiIce.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 25/10/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import Foundation
import HandyJSON

class ApiIce: HandyJSON, ApiMessage {
    
    class Params: HandyJSON {
        
        var candidate: String = ""
        var sdpMLineIndex: Int = 0
        var sdpMid: String = ""
        
        required init() {}
        
    }
    
    static var index: Int = 3
    
    static var method: String {
        return "ice"
    }
    
    static var id: Int {
        return index
    }
    
    var params: String {
        return toJSONString() ?? "{}"
    }
    
    var ice: Params?
    
    required init() {}
    
    init(candidate: String = "", sdpMLineIndex: Int = 0, sdpMid: String = "") {
        ice = ApiIce.Params().apply({
            $0.sdpMLineIndex = sdpMLineIndex
            $0.candidate = candidate
            $0.sdpMid = sdpMid
        })
    }
    
}
