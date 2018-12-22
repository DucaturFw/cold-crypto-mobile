//
//  ScannerVC.swift
//  MultiMask
//
//  Created by Kirill Kozhuhar on 04/08/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import UIKit

class ScannerVC: AlertVC {
    
    private let mView = ScannerView()

    var onFound: (String)->Void {
        get {
            return mView.onFound
        }
        set {
            mView.onFound = newValue
        }
    }
    
    init() {
        super.init(nil, view: mView, style: .sheet, arrow: true, withButtons: false, draggable: true)
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        mView.start()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stop()
    }
    
    func stop() {
        mView.stop()
    }
    
}
