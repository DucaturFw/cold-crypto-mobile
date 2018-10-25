//
//  IceCandidate.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 24/10/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import Foundation
import HandyJSON

class IceCandidate: HandyJSON {
    
    static func getMessage(sdp: String, idx: Int, mid: String, url: String) -> Message {
        return Message().apply { m in
            m.id = 3
            m.method = "ice"
            m.params = Wrapper(ice: IceCandidate().apply { i in
                i.candidate = sdp
                i.sdpMid = mid
                i.sdpMLineIndex = idx
            })
        }
    }
    
    class Wrapper: HandyJSON {
        var ice: IceCandidate?
        
        required init() {}
        
        required init(ice: IceCandidate) {
            self.ice = ice
        }
        
    }
    
    var candidate: String = ""
    var sdpMLineIndex: Int = 0
    var sdpMid: String = ""
    
    required init() {}
    
}
