//
//  IContract.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 26/11/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import Foundation

protocol IContract: class {
    var params: String { get }
    var name: String { get }
}
