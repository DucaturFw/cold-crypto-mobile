//
//  IPopover.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 05/11/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import UIKit

protocol IPopover: class {
    func show(container: UIView, completion: @escaping ()->Void)
    func hide(completion: @escaping ()->Void)
}
