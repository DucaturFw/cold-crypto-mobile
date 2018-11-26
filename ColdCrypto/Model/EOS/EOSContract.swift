//
//  EOSContract.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 26/11/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import Foundation

class EOSContract: IContract {
    
    var name: String = ""
    var params: String = ""

    init?(contract: ApiSignContractCall) {
        name = contract.tx?.transaction?.actions?.first?.name ?? contract.tx?.method ?? ""
        var tmp = ""
        contract.tx?.transaction?.actions?.first?.data?.enumerated().forEach({
             tmp += "\($0.offset+1).\t\($0.element.key) -> "
            if let arr = $0.element.value as? [AnyObject] {
                tmp += "\(arr.compactMap({ "\($0)" }).joined(separator: ", "))"
            } else {
                tmp += "\($0.element.value)"
            }
            tmp += "\n\n"
        })
        params = tmp
    }
    
}
