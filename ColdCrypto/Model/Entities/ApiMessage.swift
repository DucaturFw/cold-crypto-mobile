//
//  ApiAction.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 25/10/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import Foundation

protocol ApiMessage: class {

    static var method: String { get }
    static var id: Int { get }
    
    var params: String { get }
    
}

extension ApiMessage {
    
    func full() -> String {
        return "\(type(of: self).method)|\(type(of: self).id)|\(params)"
//        return "{\"method\":\"\(type(of: self).method)\", \"id\":\"\(type(of: self).id)\", \"params\": \(params)}"
    }
    
}
