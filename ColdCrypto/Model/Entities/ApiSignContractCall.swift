//
//  ApiSignContractCall.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 21/11/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import Foundation
import HandyJSON

class ApiSignContractCall: HandyJSON {
    
    var tx: ApiParamsTx?
    var wallet: ApiParamsWallet?
    var abi: ApiAbi?
    
    required init() {}
    
    func isValid() -> Bool {
        guard let _ = tx, let _ = wallet else { return false }
        guard let m = abi?.method, m.count > 0 else { return false }
        let data = Data(hex: m.sha3(.keccak256))
        if data.count >= 4 {
            var prefix = Data(bytes: [data[0], data[1], data[2], data[3]])
            (abi?.args ?? []).forEach({
                prefix.append(Data(hex: $0.withoutPrefix))
            })
            return prefix.toHexString().withoutPrefix == tx?.data?.withoutPrefix
        }
        return false
    }

}
