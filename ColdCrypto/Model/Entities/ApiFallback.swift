//
//  ApiFallback.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 07/12/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import Foundation
import HandyJSON

class ApiFallback: HandyJSON {
    
    static let method = "fallback"
    
    var msg: String?
    
    required init() {}
}
