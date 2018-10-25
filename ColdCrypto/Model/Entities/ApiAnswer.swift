//
//  ApiAnswer.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 25/10/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import Foundation
import HandyJSON

class ApiAnswer: HandyJSON, ApiMessage {

    static var method: String {
        return "answer"
    }
    
    static var id: Int {
        return 2
    }
    
    var answer: String? = nil
    
    required init() {}
    
    init(answer: String) {
        self.answer = answer
    }
    
    var params: String {
        return toJSONString() ?? "{}"
    }
    
}
