//
//  INetwork.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 18/12/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import Foundation

protocol INetwork {
    var name: String { get }
    var value: String { get }
    var isTest: Bool { get }
}
