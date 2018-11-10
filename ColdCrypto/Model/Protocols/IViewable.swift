//
//  IViewable.swift
//  MultiMask
//
//  Created by Kirill Kozhuhar on 20/08/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import UIKit

protocol IViewable: class {
    var text: String { get }
    var name: String { get }
    var value: String { get }
    var money: String { get }
    var icon: UIImage? { get }
    
    var order: Int { get }
}
