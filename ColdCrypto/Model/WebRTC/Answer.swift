//
//  Answer.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 24/10/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import Foundation
import HandyJSON

class Answer: HandyJSON {
    
    static func getMessage(sdp: String) -> Message {
        return Message().apply({ m in
            m.id = 2
            m.method = "answer"
            m.params = Answer().apply({ a in
                a.answer = sdp
            })
        })
    }
    
    var answer: String = ""
    required init() {}
}
