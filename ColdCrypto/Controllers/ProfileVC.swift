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

class ProfileVC: UIViewController, Signer, UIScrollViewDelegate {

    private let mBG = UIImageView(image: UIImage(named: "mainBG")).apply({
        $0.contentMode = .scaleAspectFill
    })
    
    private let mPicker: WalletPicker
    
    private var mWebRTC: RTC? = nil
    
    private lazy var mScan = ScanButton().tap({ [weak self] in
        self?.startScanning()
    })
    
    private let mPages = UIPageControl().apply({
        $0.pageIndicatorTintColor = 0xC7CCD7.color
        $0.currentPageIndicatorTintColor = 0x1888FE.color
        $0.hidesForSinglePage = true
    })
    
    private let mProfile: Profile
    
    private var mParams: String?
    
    private var defaultCatchBlock: (String)->Void {
        return { [weak self] qr in
            DispatchQueue.main.async {
                self?.showQR(text: qr)
            }
        }
    }
    
    init(profile: Profile, params: String?) {
        mProfile = profile
        mPicker  = WalletPicker(profile: mProfile)
        mParams  = params
        super.init(nibName: nil, bundle: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(close), name: .UIApplicationDidEnterBackground, object: nil)
        mPages.numberOfPages = mPicker.count
        mPicker.delegate = self
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
        view.addSubview(mPages)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        check(params: mParams)
        mParams = nil
    }
    
    func check(params: String?) {
        if let p = params {
            parse(request: p, supportRTC: true, block: defaultCatchBlock)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        mBG.frame  = view.bounds
        mPicker.frame = CGRect(x: 0, y: navigationController?.navigationBar.maxY ?? 0, width: view.width, height: view.width / 270.0 * 160.0)
        mScan.frame = CGRect(x: (view.width - 300.scaled)/2.0, y: view.height - 27.scaled - 58.scaled - view.bottomGap,
                             width: 300.scaled, height: 58.scaled)
        mPages.center = CGPoint(x: view.width/2.0, y: mPicker.maxY + 10.scaled)
    }
    
    private func startScanning() {
        let vc = ScannerVC()
        vc.onFound = { [weak self, weak vc] json in
            if let s = self, s.parse(request: json, supportRTC: true, block: s.defaultCatchBlock) == true {
                vc?.stop()
                vc?.dismiss(animated: true, completion: nil)
            }
        }
        present(UINavigationController(rootViewController: vc), animated: true, completion: nil)
    }

    private func webrtcLogin(json: String) -> Bool {
        guard let obj = ApiWebRTC.deserialize(from: json) else { return false }
        guard let sid = obj.sid, let str = obj.url, let url = URL(string: str) else { return false }
        mWebRTC?.close()
        mWebRTC = RTC(url: url, sid: sid, delegate: self)
        mWebRTC?.connect()
        return true
    }
    
    private func showQR(text: String) {
        guard var qr = QRCode(text) else { return }
        qr.size = CGSize(width: 300, height: 300)
        let malert = Malert(customView: UIImageView(image: qr.image))
        let action = MalertAction(title: "OK")
        action.tintColor = UIColor(red:0.15, green:0.64, blue:0.85, alpha:1.0)
        malert.addAction(action)
        present(malert, animated: true)
    }
    
    private func show(text: String) {
        let tmp = UIAlertController(title: nil, message: text, preferredStyle: .alert)
        tmp.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(tmp, animated: true, completion: nil)
    }

    private func addNewWallet() {
        guard let c = mProfile.chains.first(where: { $0.id == Blockchain.ETH }) else { return }
        let index = c.wallets.max(by: { $0.index < $1.index })?.index ?? 0
        guard let w = mProfile.newWallet(chain: c.id,
                                         name: "",
                                         data: String(format: "02%02x", index + 1),
                                         segwit: false) else { return }
        Settings.profile = mProfile
        mPicker.append(wallet: w)
        mPages.numberOfPages = mPicker.count
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }
    
    @objc private func close() {
        dismiss(animated: true, completion: nil)
        mWebRTC?.close()
        mWebRTC = nil
    }
    
    // MARK: - Signer methods
    // -------------------------------------------------------------------------
    @discardableResult
    func parse(request: String, supportRTC: Bool, block: @escaping (String)->Void) -> Bool {
        let parts = request.split(separator: "|", maxSplits: Int.max, omittingEmptySubsequences: false)
        var catched: Bool = false
        if parts.count > 2, let id = Int(parts[1]) {
            let json = String(parts[2])
            switch parts[0] {
            case "payToAddress": catched = payToAddress(json: json, id: id, completion: block)
            case "signTransferTx": catched = signTransferTx(json: json, id: id, completion: block)
            case "getWalletList": catched = getWalletList(json: json, id: id, completion: block)
            case "webrtcLogin": if supportRTC { catched = webrtcLogin(json: json) }
            default: catched = false
            }
        }
        return catched
    }
    
    @discardableResult
    func payToAddress(json: String, id: Int, completion: @escaping (String)->Void) -> Bool {
        guard let c = ApiPay.deserialize(from: json) else { return false }
        let bb = (c.blockchain ?? "eth").uppercased()
        guard let b = Blockchain(rawValue: bb) else { return false }
        guard let wallets = mProfile.chains.first(where: { $0.id == b })?.wallets, wallets.count > 0 else { return false }
        let w = mPages.currentPage < wallets.count ? wallets[mPages.currentPage] : wallets[0]
        DispatchQueue.main.async {
            let hud = self.view.window?.hud
            w.pay(to: c, completion: { txHash in
                hud?.hide(animated: true)
                if let tx = txHash {
                    if let callback = c.callback, let url = URL(string: callback) {
                        UIApplication.shared.open(url.append("txHash", value: tx), options: [:], completionHandler: nil)
                    } else {
                        completion("|\(id)|\"\(tx)\"")
                    }
                    print("\(tx)")
                } else {
                    self.show(text: "Can't pay")
                }
            })
        }
        return true
    }
    
    @discardableResult
    func getWalletList(json: String, id: Int, completion: @escaping (String)->Void) -> Bool {
        guard let c = ApiChains.deserialize(from: json) else { return false }
        let chains = mProfile.chains.filter({ c.blockchains.contains($0.id.rawValue.lowercased()) })
        guard let str = chains.flatMap({ oc in
            oc.wallets.compactMap({ ow in
                ApiParamsWallet(b: ow.blockchain.rawValue.lowercased(), a: ow.address, c: 4)
            })
        }).toJSONString() else { return false }
        completion("|\(id)|\(str)")
        return true
    }
    
    @discardableResult
    func signTransferTx(json: String, id: Int, completion: @escaping (String)->Void) -> Bool {
        guard let tx = ApiSign.deserialize(from: json) else { return false }
        guard let b = tx.wallet, let to = tx.tx else { return false }
        guard let blockchain = Blockchain(rawValue: b.blockchain.uppercased()) else { return false }
        guard let wallet = mProfile.chains.first(where: { $0.id == blockchain })?.wallets.first(where: { $0.address == b.address }) else { return false }
        DispatchQueue.main.async {
            self.present(ConfirmationVC(to: to, onConfirm: { [weak self] in
                self?.dismiss(animated: true, completion: nil)
                guard let tx = wallet.getTransaction(to: to, with: b) else { return }
                completion("|\(id)|\"\(tx)\"")
            }), animated: true, completion: nil)
        }
        return true
    }
    
    // MARK: - UIScrollViewDelegate methods
    // -------------------------------------------------------------------------
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard mPicker.width > 0 else { return }
        let p = mPicker.contentOffset.x / mPicker.width
        mPages.currentPage = Int((p - floor(p) > 0.9) ? ceil(p) : floor(p))
    }
    
}
