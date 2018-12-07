//
//  ApiIceServer.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 07/12/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import Foundation
import HandyJSON

class ApiIceServer: HandyJSON {
    
    static let method: String = "turn"
    
    var credential: String?
    var username: String?
    var urls: [String]?

    required init() {}
    
}
