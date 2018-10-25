//
//  Join.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 24/10/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import Foundation
import HandyJSON

class Join: HandyJSON {
    
    static func getMessage(sid: String) -> Message {
        return Message().apply {
            $0.id = 1
            $0.method = "join"
            $0.params = Join().apply { j in
                j.sid = sid
            }
        }
    }
    
    var sid: String = ""
    
    required init() {}
    
}
