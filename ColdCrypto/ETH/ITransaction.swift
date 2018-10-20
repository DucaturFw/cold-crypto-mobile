//
//  ITransaction.swift
//  MultiMask
//
//  Created by Kirill Kozhuhar on 07/10/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import Foundation

protocol ITransaction: IViewable {
    
    var tokenSymbol: String { get }
    var blockchain: Blockchain { get }
    var positive: Bool { get }
    var hash: String { get }
    var from: String { get }
    var val: String { get }
    var to: String { get }
    
}
