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

class ProfileVC: UIViewController {

    private let mBG = UIImageView(image: UIImage(named: "mainBG")).apply({
        $0.contentMode = .scaleAspectFill
    })
    
    private let mPicker = ChainPicker()
    
    private lazy var mScan = ScanButton().tap({ [weak self] in
        self?.startScanning()
    })
    
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
        navigationItem.titleView = UIImageView(image: UIImage(named: "smallLogo"))
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: UIImageView(image: UIImage(named: "add")).tap({ [weak self] in
            self?.addNewWallet()
        }).apply({
            $0.contentMode = .center
            $0.frame = $0.frame.insetBy(dx: -10, dy: -10)
        }))
        view.backgroundColor = .white
        view.addSubview(mBG)
        view.addSubview(mPicker)
        view.addSubview(mScan)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        mBG.frame  = view.bounds
        mPicker.frame = CGRect(x: 0, y: navigationController?.navigationBar.maxY ?? 0, width: view.width, height: view.width / 270.0 * 160.0)
        mScan.frame = CGRect(x: (view.width - 300.scaled)/2.0, y: view.height - 27.scaled - 58.scaled,
                             width: 300.scaled, height: 58.scaled)
    }

    private func startScanning() {
        let vc = ScannerVC()
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
        
        scanner?.stop()
        scanner?.dismiss(animated: true, completion: nil)
        present(ConfirmationVC(to: to, onConfirm: { [weak self] in
            self?.dismiss(animated: true, completion: nil)
            self?.sign(to: to, b: b, wallet: wallet)
        }), animated: true, completion: nil)
    }
    
    private func sign(to: ApiDestination, b: ApiWallet, wallet: IWallet) {
        guard let tx = wallet.getTransaction(to: to, with: b) else { return }
        guard var qr = QRCode(tx) else { return }
        qr.size = CGSize(width: 300, height: 300)
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
    
    private func addNewWallet() {
        print("asd")
    }
    
}
