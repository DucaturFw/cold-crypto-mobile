//
//  MoreVC.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 04/12/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import Foundation
import QRCode

class MoreVC: AlertVC {
    
    var onDelete: (IWallet)->Void = { _ in }
    
    init(passcode: String, wallet: IWallet) {
        let v = MorePicker()
        super.init(nil, view: v, style: .sheet, arrow: true, withButtons: false)
        v.onSend = { [weak self] in
            if let s = self {
                self?.update(view: NewTransaction(parent: s), configure: {})
            }
        }
        v.onDelete = { [weak self] in
            self?.update(view: DeleteView(), configure: { [weak self] in
                self?.withButtons = true
                self?.put("delete_no".loc)
                self?.put("delete_yes".loc, color: Style.Colors.red, do: { [weak self] _ in
                    DispatchQueue.main.async {
                        self?.onDelete(wallet)
                    }
                })
            }, animate: { [weak self] in
                self?.style = .alert
                self?.withArrow = false
            })
        }
        v.onBackup = { [weak self] in
            self?.backup(passcode: passcode, wallet: wallet)
        }
        v.onReceive = { [weak self] in
            guard var qr = QRCode(wallet.address) else {
                self?.dismiss(animated: true)
                return
            }
            qr.size = CGSize(width: 300, height: 300)
            self?.update(view: AlertImage(image: qr.image), configure: { [weak self] in
                self?.put("share".loc) { _ in
                    DispatchQueue.main.async {
                        AppDelegate.share(image: qr.image, text: wallet.address)
                    }
                }
            })
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    private func backup(passcode: String, wallet: IWallet) {
        present(CheckCodeVC(passcode: passcode, authAtStart: true, onSuccess: { [weak self] vc in
            vc.dismiss(animated: true, completion: { [weak self] in
                if let seed = wallet.seed {
                    self?.update(view: BackupView(seed: seed), configure: { [weak self] in
                        self?.put("done".loc)
                    })
                } else if var qr = QRCode(wallet.privateKey) {
                    qr.size = CGSize(width: 300, height: 300)
                    self?.update(view: AlertImage(image: qr.image), configure: { [weak self] in
                        self?.put("share".loc, do: { _ in
                            DispatchQueue.main.async {
                                AppDelegate.share(image: qr.image, text: wallet.privateKey)
                            }
                        })
                    })
                }
            })
        }).apply({
            $0.hintText = "confirm_hint".loc
        }).inNC, animated: true, completion: nil)

    }
    
}
