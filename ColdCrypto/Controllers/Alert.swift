//
//  Alert.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 20/10/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import UIKit

class Alert : UIAlertController {
    
    convenience init(message: String) {
        self.init(title: nil, message: message, preferredStyle: UIAlertControllerStyle.alert)
    }
    
    func set(positive: String, do block: ((Alert)->Void)? = nil) -> Self {
        addAction(UIAlertAction(title: positive, style: .default, handler: { [weak self] _ in
            if let s = self {
                block?(s)
            }
        }))
        return self
    }
    
    func set(negative: String, do block: ((Alert)->Void)? = nil) -> Self {
        addAction(UIAlertAction(title: negative, style: .cancel, handler: { [weak self] _ in
            if let s = self {
                block?(s)
            }
        }))
        return self
    }
    
}
