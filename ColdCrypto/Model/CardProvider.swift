//
//  CardProvider.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 01/12/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import Foundation

class CardProvider {
    
    private static let mCards = (0...3).compactMap({ UIImage(named: "card\($0)") })
    private static var mTints = (0...3).compactMap({ UIImage(named: "card\($0)Tint") })
    private static var mCache = [String: (UIImage?, UIImage?)]()
    
    static func getCard(_ seed: String) -> UIImage? {
        if let img = mCache[seed] { return img.0 ?? CardProvider.mCards[0] }
        let i = MyBlockiesHelper.createRandSeed(seed: seed)
        if i.count >= 4 {
            let color = (Int(i[2] % 255) << 16 | Int(i[1] % 255) << 8 | Int(i[0] % 255)).color
            let image = CardProvider.mCards[Int(i[2] % 255)%CardProvider.mCards.count].tint(tintColor: color)
            let tints = CardProvider.mTints[Int(i[2] % 255)%CardProvider.mTints.count].tint(tintColor: color)
            mCache[seed] = (image, tints)
            return image
        }
        return CardProvider.mCards[0]
    }
    
    static func getTint(_ seed: String) -> UIImage? {
        return mCache[seed]?.1 ?? CardProvider.mTints[0]
    }
    
}
