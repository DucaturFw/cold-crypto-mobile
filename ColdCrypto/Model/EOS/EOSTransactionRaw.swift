//
//  EOSRawTransaction.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 05/12/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import Foundation
import HandyJSON

class EOSTransactionRaw: HandyJSON {
    
    var hash: String = ""
    var another_account: String = ""
    var trx_timestamp: String = ""
    var quantity: String = ""
    var symbol: String = ""
    var direction: String = ""
    
    required init() {}
}
