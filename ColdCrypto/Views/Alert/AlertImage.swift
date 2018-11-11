//
//  AlertImage.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 11/11/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import UIKit

class AlertImage: UIImageView, IAlertView {
    
    func sizeFor(width: CGFloat) -> CGSize {
        if let img = image {
            return img.size.width > width ? CGSize(width: width, height: img.size.height * width / img.size.width) : img.size
        }
        return .zero
    }
    
    func focusAtStart() {}
    
    var value: String {
        return ""
    }
    
}
