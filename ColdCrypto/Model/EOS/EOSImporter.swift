//
//  EOSImporter.swift
//  MultiMask
//
//  Created by Kirill Kozhuhar on 16/11/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import UIKit
import AVFoundation

class EOSImporter {
    
    private static let noAcc = UILabel.new(font: UIFont.hnRegular(16),
                                           text: "no_acccount_eos".loc,
                                           lines: 1,
                                           color: .black,
                                           alignment: .center)
    
    private static let incorrect = UILabel.new(font: UIFont.hnRegular(16),
                                               text: "cant_import".loc,
                                               lines: 1,
                                               color: .black,
                                               alignment: .center)
    
    static func importWallet(from: UIViewController, completion: @escaping (EOSWallet?)->Void) {
        AlertOld(message: "seed_pk".loc, style: .withFieldCamera)
            .set(negative: "cancel".loc)
            .set(positive: "import".loc, hide: false, do: { a in
                let value = a.value
                if value.count > 0 {
                    a.endEditing(true)
                    do {
                        let parts = value.split(separator: " ")
                        let pk = parts.count == 1 ? try PrivateKey(keyString: value) : try PrivateKey(mnemonicString: value, index: 0)
                        guard let pk2 = pk else {
                            throw "PK is null"
                        }
                        let hud = HUD.show()
                        
                        print("\(PublicKey(privateKey: pk2).rawPublicKey())")
                        
                        EOSRPC.sharedInstance.getKeyAccounts(pub: PublicKey(privateKey: pk2).rawPublicKey(), completion: { r, e in
                            hud?.hide(animated: true)
                            if let accs = r?.accountNames, accs.count > 0 {
                                let v = AccountPicker(accounts: accs)
                                v.onPicked = { [weak a] acc in
                                    a?.hide()
                                    completion(EOSWallet(name: acc, data: "00\(value)", privateKey: value))
                                }
                                a.set(customView: v, animated: true)
                            } else if a.customView != noAcc {
                                a.set(customView: noAcc, animated: true)
                            } else {
                                a.customView?.shake()
                            }
                        })
                    } catch let e {
                        print("\(e)")
                        if a.customView != incorrect {
                            a.set(customView: incorrect, animated: true)
                        } else {
                            a.customView?.shake()
                        }
                    }
                }
            }).onScan(do: { [weak from] a in
                guard let s = from else { return }
                let vc = ScannerVC()
                vc.onFound = { [weak vc, weak a] key in
                    a?.value = key
                    vc?.stop()
                    vc?.dismiss(animated: true, completion: nil)
                    AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                }
                s.present(vc, animated: true)
            }).show(in: from.view)
    }
    
}
