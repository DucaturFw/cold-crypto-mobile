//
//  TokenHistory.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 03/03/2019.
//  Copyright © 2019 Kirill Kozhuhar. All rights reserved.
//

import Foundation

extension String {
    var int: Int? {
        return Int(self)
    }
}

class TokenHistoryEOS: Decodable {
    
    class TokenEOS: Decodable {
        var balance: String?
        var symbol: String?
        var code: String?
    }
    
    class DataEOS: Decodable {
        var symbol_list: [TokenEOS]?
    }
    
    var data: DataEOS?
    
}

class TokenHistory: Decodable {
    
    class TokenInfo: Decodable {
        var decimals: String?
        var address: String?
        var symbol: String?
        var name: String?
    }
    
    class Token: Decodable {
        var balance: Decimal?
        var tokenInfo: TokenInfo?
    }
    
    var tokens: [Token]?
    
}
