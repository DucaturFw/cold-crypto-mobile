//
//  IAlertView.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 11/11/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import UIKit

protocol IAlertView: class {
    func sizeFor(width: CGFloat) -> CGSize
    func focusAtStart()
    var value: String { get }
}
