//
//  ViewController.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 18/10/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import Malert
import QRCode
import UIKit

class ViewController: UIViewController {

    private lazy var scan: Button = {
        let tmp = Button()
        tmp.backgroundColor = 0x1888FE.color
        tmp.setTitle("scan".loc, for: UIControlState.normal)
        tmp.layer.shadowColor  = 0xB8CEFD.color.cgColor
        tmp.layer.shadowOffset = CGSize(width: 0, height: 5.scaled)
        tmp.layer.shadowRadius = 40.scaled
        tmp.layer.shadowOpacity = 1.0
        return tmp
    }()
    
    private let mProfile: Profile
    
    init(profile: Profile) {
        mProfile = profile
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(scan)
        view.backgroundColor = .white
        scan.tap({ [weak self] in
            self?.startScanning()
        })
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scan.frame = CGRect(x: (view.width - 100)/2.0, y: (view.height - 100)/2.0, width: 100, height: 100)
    }

    private func startScanning() {
        let vc = ScannerVC(backStyle: .toPrevious, hintStyle: .address)
        vc.onFound = { [weak self, weak vc] json in
            let parts = json.split(separator: "|")
            if parts.count >= 2 {
                let params = String(parts.count > 2 ? parts[2] : parts[1])
                switch parts[0] {
                case "signTransferTx": self?.signTransferTx(json: params, scanner: vc)
                case "getWalletList": self?.getWalletList(json: params, scanner: vc)
                default: break
                }
            }
        }
        present(UINavigationController(rootViewController: vc), animated: true, completion: nil)
    }
    
    private func signTransferTx(json: String, scanner: ScannerVC?) {
        guard let j = try? JSONSerialization.jsonObject(with: json.toData(), options: []) else { return }
        guard let s = j as? [[String: Any]], s.count >= 2 else { return }
        guard let b = ApiWallet.deserialize(from: s[1]) else { return }
        guard let to = ApiDestination.deserialize(from: s[0]) else { return }
        guard let blockchain = Blockchain(rawValue: b.blockchain.uppercased()) else { return }
        guard let wallet = mProfile.chains.first(where: { $0.id == blockchain })?.wallets.first(where: { $0.address == b.address }) else { return }
        guard let tx = wallet.getTransaction(to: to, with: b) else { return }
        guard var qr = QRCode(tx) else { return }
        qr.size = CGSize(width: 300, height: 300)

        scanner?.stop()
        scanner?.dismiss(animated: true, completion: nil)
        
        let malert = Malert(customView: UIImageView(image: qr.image))
        let action = MalertAction(title: "OK")
        action.tintColor = UIColor(red:0.15, green:0.64, blue:0.85, alpha:1.0)
        malert.addAction(action)
        present(malert, animated: true)
    }
    
    private func getWalletList(json: String, scanner: ScannerVC?) {
        guard let j = try? JSONSerialization.jsonObject(with: json.toData(), options: []) else { return }
        guard let p = j as? [[String]], p.count > 0 else { return }

        let s = p[0].compactMap({ Blockchain(rawValue: $0.uppercased()) })
        let c = mProfile.chains.filter({ s.contains($0.id) })
        guard c.count > 0, let str = c.flatMap({ oc in
            oc.wallets.compactMap({ ow in
                ApiWallet(b: ow.blockchain.rawValue.lowercased(), a: ow.address, c: 4)
            })
        }).toJSONString() else { return }
        guard var qr = QRCode(str) else { return }
        qr.size = CGSize(width: 300, height: 300)
        
        scanner?.stop()
        scanner?.dismiss(animated: true, completion: nil)
        
        let malert = Malert(customView: UIImageView(image: qr.image))
        let action = MalertAction(title: "OK")
        action.tintColor = UIColor(red:0.15, green:0.64, blue:0.85, alpha:1.0)
        malert.addAction(action)
        present(malert, animated: true)
    }
    
}
