//
//  Token.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 03/03/2019.
//  Copyright © 2019 Kirill Kozhuhar. All rights reserved.
//

import Foundation

class TokenObj {
    var name: String
    var amount: Decimal
    var address: String
    var decimal: Int
    
    init(name: String, amount: Decimal, address: String, decimal: Int) {
        self.name = name
        self.amount = amount
        self.address = address
        self.decimal = decimal
    }
}
