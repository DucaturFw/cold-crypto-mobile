//
//  IToken.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 05/12/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import Foundation

protocol IToken {
    
    var decimal: Int { get }
    var balance: String { get }
    var symbol: String { get }
    var amount: Int64 { get set }
    var name: String { get }
    var text: String { get }
    var icon: UIImage? { get }
    
    func isValid(address: String) -> Bool
    func send(to: String, amount: Decimal, completion: @escaping (String?)->Void)
    
}
