//
//  ISigner.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 19/12/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import Foundation

protocol ISigner: class {    
    @discardableResult
    func parse(request: String, supportRTC: Bool, block: @escaping (String)->Void) -> Bool
}
