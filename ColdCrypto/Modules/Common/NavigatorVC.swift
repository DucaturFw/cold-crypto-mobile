//
//  NavigatorVC.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 01/12/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import UIKit

class NavigatorVC: UINavigationController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return viewControllers.last?.preferredStatusBarStyle ?? .lightContent
    }
    
}
