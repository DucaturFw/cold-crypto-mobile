//
//  AlertImage.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 11/11/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import UIKit

class AlertImage: UIImageView, IAlertView {
    
    func layout(width: CGFloat, origin o: CGPoint) {
        if self.width > 0 && self.height > 0 {
            let w = self.width > width ? width : self.width
            let h = w * self.height / self.width
            frame = CGRect(x: o.x + (width - w)/2.0, y: o.y, width: w, height: h)
        }
    }

}
