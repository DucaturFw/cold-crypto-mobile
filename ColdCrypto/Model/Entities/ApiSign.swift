//
//  ApiSign.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 24/10/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import HandyJSON

class ApiSign: HandyJSON {
    
    var wallet: ApiParamsWallet?
    var tx: ApiParamsTx?
    
    required init() {}
    
}
