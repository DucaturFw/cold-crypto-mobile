//
//  ETHContract.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 26/11/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import Foundation
import HandyJSON

class ETHContract: IContract {
    
    class ContractImpl: HandyJSON {
        
        class Param: HandyJSON {
            
            var name:  String?
            var value: AnyObject?
            var type:  String?
            
            required init() {}
            
        }
        
        var name: String?
        var params: [Param]?
        
        required init() {}
        
    }
    
    private let mCont: ContractImpl
    
    var name: String {
        return mCont.name ?? ""
    }
    
    var params: String {
        var text = ""
        mCont.params?.enumerated().forEach({
            let type = $0.element.type ?? ""
            text += "\($0.offset+1).\t\(type) -> "
            if let value = $0.element.value as? [String] {
                text += "\(value.joined(separator: ", "))"
            } else {
                text += "\(($0.element.value as? String) ?? "")"
            }
            text += "\n\n"
        })
        return text
    }
    
    init?(contract: ApiSignContractCall) {
        guard let call = contract.abi?.method else { return nil }
        guard let data = contract.tx?.data else { return nil }
        guard let pack = ETHabi.convert(call: call, data: data) else { return nil }
        guard let cont = ContractImpl.deserialize(from: pack) else { return nil }
        mCont = cont
    }

}
