//
//  EOSActions.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 05/12/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import Foundation
import HandyJSON

class EOSActions: HandyJSON {
    
    class Data: HandyJSON {
        
        var from: String?
        var to: String?
        var quantity: String?
        var memo: String?
        var time: String?
        var id: String?
        
        required init() {}
    }
    
    class Act: HandyJSON {
        var data: Data?
        required init() {}
    }
    
    class EOSAction: HandyJSON {
        
        class Trace: HandyJSON {
            var act: Act?
            var trx_id: String?
            var block_time: String?
            required init() {}
        }
        
        var action_trace: Trace?
        
        required init() {}
        
    }
    
    var actions: [EOSAction]?
    
    required init() {}
    
}
