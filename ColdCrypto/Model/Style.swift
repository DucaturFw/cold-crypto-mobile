//
//  Style.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 01/12/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import UIKit

struct Style {
    struct Colors {
        static let red   = 0xF33C29.color
        static let blue  = 0x00BCF9.color
        static let tint  = 0x000000.color.withAlphaComponent(0.6)
        static let white = 0xFFFFFF.color
        static let light = 0xF3F2F4.color
        static let black = 0x160A2E.color
        static let green = 0x63BE6B.color
        static let darkGrey = 0x736C82.color
        static let darkLight = 0xBAB6C1.color
    }
    struct Dims {
        static let buttonSmall  = 30.scaled
        static let buttonMiddle = 40.scaled
        static let buttonLarge  = 50.scaled
        static let bottomScan   = 160.scaled
    }
}
