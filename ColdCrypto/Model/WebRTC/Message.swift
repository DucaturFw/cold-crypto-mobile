//
//  Message.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 24/10/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import UIKit
import HandyJSON

class Message : HandyJSON {
    
    var jsonrpc: String = "2.0"
    var method: String?
    var id: Int?
    var params: HandyJSON?
    
    required init() {}
    
}
