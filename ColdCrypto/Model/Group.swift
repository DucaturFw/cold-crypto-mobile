//
//  Group.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 01/12/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import Foundation

class Group {
    
    private let mCount: Int
    private var mCurrent: Int = 0
    private let mDone: ()->Void
    
    init(_ amount: Int, _ done: @escaping ()->Void) {
        mCount = amount
        mDone  = done
    }
    
    func done() {
        DispatchQueue.main.async {
            if self.mCurrent >= self.mCount { return }
            self.mCurrent += 1
            if self.mCurrent == self.mCount {
                self.mDone()
            }
        }
    }
    
}
