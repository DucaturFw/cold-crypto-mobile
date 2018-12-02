//
//  BackupVC.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 11/11/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import UIKit
import QRCode

class BackupVC: AlertVC {
    
    init(seed: String) {
        super.init(view: BackupView(seed: seed), arrow: true)
        put("done".loc)
    }
    
    init?(pk: String) {
        guard var qr = QRCode(pk) else { return nil }
        qr.size = CGSize(width: 300, height: 300)
        super.init(view: AlertImage(image: qr.image), arrow: true)
        put("share".loc, do: { _ in
            AppDelegate.share(image: qr.image, text: pk)
        })
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }

}
