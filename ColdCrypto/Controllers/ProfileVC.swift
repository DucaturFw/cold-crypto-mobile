//
//  ViewController.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 18/10/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import QRCode
import UIKit
import JTHamburgerButton

class ProfileVC: UIViewController, Signer, ImportDelegate {

    private let mBG = UIImageView(image: UIImage(named: "mainBG")).apply({
        $0.contentMode = .scaleAspectFill
    })
        
    private var mWebRTC: RTC? = nil
    
    private let mScan = ScanButton()

    private let mProfile: Profile
    
    private var mParams: String?
    
    private lazy var mRightAdd = UIImageView(image: UIImage(named: "add")).tap({ [weak self] in
        self?.mImportManager.addNewWallet()
    }).apply({
        $0.contentMode = .center
        $0.frame = $0.frame.insetBy(dx: -10, dy: -10)
    })
    
    private lazy var mLeftMenu = JTHamburgerButton(frame: CGRect(x: 0, y: 0, width: 18, height: 16)).apply({
        $0.lineColor = 0x007AFF.color
        $0.lineSpacing = 5.0
        $0.lineWidth = 24
        $0.lineHeight = 2
    }).tap({ [weak self] in
        self?.present(AppDelegate.menu, animated: true, completion: nil)
    })
    
    private var scanMinY: CGFloat {
        return 84.scaled + view.bottomGap
    }
    
    private var defaultCatchBlock: (String)->Void {
        return { [weak self] qr in
            DispatchQueue.main.async {
                self?.show(qr: qr)
            }
        }
    }
    
    private lazy var mView = CardsList(frame: UIScreen.main.bounds).apply({ [weak self] v in
        v.onBackUp = { [weak self] w in
            self?.backup(wallet: w)
        }
        v.onDelete = { [weak self] w in
            self?.delete(wallet: w)
        }
        v.onActive = { [weak self] w in
            self?.mActiveWallet = w
        }
    })
    
    private var mActiveWallet: IWallet? {
        didSet {
            refreshLayout()
        }
    }
    
    private let mPasscode: String
    
    private lazy var mImportManager = ImportManager(parent: self)
    
    init(profile: Profile, passcode: String, params: String?) {
        mPasscode = passcode
        mProfile  = profile
        mParams   = params
        super.init(nibName: nil, bundle: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(close), name: UIApplication.didEnterBackgroundNotification, object: nil)
        mView.wallets = mProfile.chains.flatMap({ $0.wallets })
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.titleView = UIImageView(image: UIImage(named: "smallLogo"))
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: mRightAdd)
        navigationItem.leftBarButtonItem  = UIBarButtonItem(customView: mLeftMenu)
        view.backgroundColor = .white
        view.addSubview(mBG)
        view.addSubview(mView)
        view.addSubview(mScan)
        mScan.tap({ [weak self] in
            self?.startScanning()
        })
    }
    
    override func sideMenuDidAppear(animated: Bool) {
        mLeftMenu.setCurrentModeWithAnimation(JTHamburgerButtonMode.arrow)
    }
    
    override func sideMenuDidDisappear(animated: Bool) {
        mLeftMenu.setCurrentModeWithAnimation(JTHamburgerButtonMode.hamburger)
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
    
    private func refreshLayout() {
        let w = mActiveWallet
        mScan.transform = CGAffineTransform(translationX: 0, y: w == nil  ? self.scanMinY : 0)
        mLeftMenu.isUserInteractionEnabled = (w == nil)
        mRightAdd.isUserInteractionEnabled = mLeftMenu.isUserInteractionEnabled
        mLeftMenu.alpha = (w == nil ? 1.0 : 0.0)
        mRightAdd.alpha = mLeftMenu.alpha
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        mBG.frame = view.bounds
        mView.frame = view.bounds
        
        refreshLayout()

        let t = mScan.transform
        mScan.transform = .identity
        mScan.frame = CGRect(x: 34.scaled, y: view.height - scanMinY, width: view.width - 68.scaled, height: 57.scaled)
        mScan.transform = t
    }
    
    private func startScanning() {
//        // TODO: REMOVE THIS
//        if let path = Bundle.main.path(forResource: "abi_mock.json", ofType: nil), let str = try? String(contentsOfFile: path) {
//            parse(request: "signContractCall|3|\(str)", supportRTC: false, block: { resp in
//                print("\(resp   )")
//            })
//            return
//        }
        let vc = ScannerVC()
        vc.onFound = { [weak self, weak vc] json in
            if let s = self, s.parse(request: json, supportRTC: true, block: s.defaultCatchBlock) == true {
                vc?.stop()
                vc?.dismiss(animated: true, completion: nil)
            }
        }
        present(vc, animated: true, completion: nil)
    }

    private func webrtcLogin(json: String) -> Bool {
        guard let obj = ApiWebRTC.deserialize(from: json) else { return false }
        guard let sid = obj.sid, let str = obj.url, let url = URL(string: str) else { return false }
        mWebRTC?.close()
        mWebRTC = RTC(url: url, sid: sid, delegate: self)
        mWebRTC?.connect()
        return true
    }
    
    private func show(qr text: String) {
        guard var qr = QRCode(text) else { return }
        qr.size = CGSize(width: 300, height: 300)
        Alert(view: AlertImage(image: qr.image)).show()
    }
    
    private func delete(wallet: IWallet) {
        Alert("sure_delete".loc).put("delete_no".loc)
            .put("delete_yes".loc, color: 0xE26E7C.color, do: { [weak self] _ in
                self?.sureDelete(wallet: wallet)
            }).show()
    }
    
    private func sureDelete(wallet: IWallet) {
        present(CheckCodeVC(passcode: mPasscode, authAtStart: true, onSuccess: { [weak self] vc in
            vc.dismiss(animated: true, completion: { [weak self] in
                if let s = self {
                    s.mView.close {
                        s.mProfile.chains.forEach({
                            $0.wallets.removeAll(where: { $0.privateKey == wallet.privateKey })
                        })
                        Settings.profile = s.mProfile
                        s.mView.delete(wallet: wallet)
                    }
                }
            })
        }).apply({
            $0.hintText = "confirm_hint".loc
        }), animated: true, completion: nil)
    }
    
    private func backup(wallet: IWallet) {
        present(CheckCodeVC(passcode: mPasscode, authAtStart: true, onSuccess: { [weak self] vc in
            vc.dismiss(animated: true, completion: { [weak self] in
                if let seed = wallet.seed {
                    self?.backup(seed: seed)
                } else {
                    self?.backup(pk: wallet.privateKey)
                }
            })
        }).apply({
            $0.hintText = "confirm_hint".loc
        }), animated: true, completion: nil)
    }
    
    private func backup(seed: String) {
        present(BackupVC(seed: seed), animated: true, completion: nil)
    }
    
    private func backup(pk: String) {
        guard var qr = QRCode(pk) else { return }
        qr.size = CGSize(width: 300, height: 300)
        Alert(view: AlertImage(image: qr.image))
            .put(negative: "ok".loc)
            .put("share".loc, do: { [weak self] _ in
                self?.share(image: qr.image, text: pk)
            })
            .show()
    }
    
    @objc private func close() {
        mWebRTC?.close()
        mWebRTC = nil
        
        dismiss(animated: false, completion: nil)
        present(CheckCodeVC(passcode: mPasscode,
                            canSkip: false,
                            onSuccess: { vc in vc.dismiss(animated: true, completion: nil) }),
                animated: false,
                completion: nil)
    }
    
    private func share(image: UIImage?, text: String) {
        var shareItems: [Any] = [text]
        if let i = image {
            shareItems.append(i)
        }
        present(UIActivityViewController(activityItems: shareItems, applicationActivities: nil), animated: true, completion: nil)
    }
    
    // MARK: - Signer methods
    // -------------------------------------------------------------------------
    @discardableResult
    func parse(request: String, supportRTC: Bool, block: @escaping (String)->Void) -> Bool {
        
        print("\(request)")
        
        let parts = request.split(separator: "|", maxSplits: Int.max, omittingEmptySubsequences: false)
        var catched: Bool = false
        if parts.count > 2, let id = Int(parts[1]) {
            let json = String(parts[2])
            switch parts[0] {
            case "payToAddress": catched = payToAddress(json: json, id: id, completion: block)
            case "signTransferTx": catched = signTransferTx(json: json, id: id, completion: block)
            case "getWalletList": catched = getWalletList(json: json, id: id, completion: block)
            case "webrtcLogin": if supportRTC { catched = webrtcLogin(json: json) }
            case "signContractCall": catched = signContractCall(json: json, id: id, completion: block)
            default: catched = false
            }
        }
        return catched
    }
    
    @discardableResult
    func signContractCall(json: String, id: Int, completion: @escaping (String)->Void) -> Bool {
        guard let w = mActiveWallet else { return false }
        guard let p = ApiSignContractCall.deserialize(from: json) else { return false }
        DispatchQueue.main.async {
            self.present(ConfirmContractCall(contract: p, wallet: w, passcode: self.mPasscode, completion: { [weak self] signed in
                if let s = signed {
                    self?.dismiss(animated: true, completion: nil)
                    completion("|\(id)|\"\(s)\"")
                } else {
                    Alert("cant_signed".loc).show()
                }
            }), animated: true, completion: nil)
        }
        return true
    }
    
    @discardableResult
    func payToAddress(json: String, id: Int, completion: @escaping (String)->Void) -> Bool {
        guard let c = ApiPay.deserialize(from: json) else { return false }
        let bb = (c.blockchain ?? "eth").uppercased()
        guard let b = Blockchain(rawValue: bb) else { return false }
        if let w = mActiveWallet {
            DispatchQueue.main.async {
                self.pay(c: c, from: w, json: json, id: id, completion: completion)
            }
        } else {
            DispatchQueue.main.async {
                self.present(CardPickVC(profile: self.mProfile, blockchain: b, completion: { [weak self] w in
                    if let w = w {
                        self?.pay(c: c, from: w, json: json, id: id, completion: completion)
                    }
                }), animated: true, completion: nil)
            }
        }
        return true
    }
    
    private func pay(c: ApiPay, from: IWallet, json: String, id: Int, completion: @escaping (String)->Void) {
        self.present(ConfirmationVC(to: c.to, amount: c.amountFormatted, onConfirm: { [weak self] in
            guard let s = self else { return }
            s.dismiss(animated: true, completion: {
                let hud = s.view.window?.hud
                from.pay(to: c, completion: { txHash in
                    hud?.hide(animated: true)
                    if let tx = txHash {
                        if let callback = c.callback, let url = URL(string: callback) {
                            UIApplication.shared.open(url.append("txHash", value: tx), options: [:], completionHandler: nil)
                        } else {
                            completion("|\(id)|\"\(tx)\"")
                        }
                    } else {
                        Alert("Can't pay").show()
                    }
                })
            })
        }), animated: true, completion: nil)
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
            self.present(ConfirmationVC(to: to.to, amount: to.amountFormatted, onConfirm: { [weak self] in
                self?.dismiss(animated: true, completion: nil)
                guard let tx = wallet.getTransaction(to: to, with: b) else { return }
                completion("|\(id)|\"\(tx)\"")
            }), animated: true, completion: nil)
        }
        return true
    }
    
    // MARK: - ImportDelegate methods
    // -------------------------------------------------------------------------
    func onNew(chain: Blockchain, name: String, data: String, segwit: Bool) {
        guard let w = mProfile.newWallet(chain: chain,
                                         name: name,
                                         data: data,
                                         segwit: segwit) else { return }
        Settings.profile = mProfile
        mView.add(wallet: w)
    }
    
    func onNewHDWallet(chain: Blockchain) {
        guard let w = mProfile.newWallet(chain: chain,
                                         name: "",
                                         data: String(format: "02%02x", mProfile.index + 1),
                                         segwit: false) else { return }
        mProfile.index += 1
        Settings.profile = mProfile
        mView.add(wallet: w)
    }
    
}
