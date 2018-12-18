//
//  ViewController.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 18/10/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import QRCode
import UIKit

class ProfileVC: UIViewController, Signer, ImportDelegate {

    private var mWebRTC: RTC? = nil
    
    private lazy var mScan = ScanBlock().apply({
        $0.onScan = { [weak self] in
            self?.startScanning()
        }
        $0.onMore = { [weak self] in
            if let w = self?.mActiveWallet {
                self?.showMore(for: w)
            }
        }
    })

    private let mProfile: Profile
    
    private var mParams: String?

    override var preferredStatusBarStyle: UIStatusBarStyle {
        if let p = presentedViewController, !p.isBeingDismissed {
            return p.preferredStatusBarStyle
        }
        return .default
    }
    
    private lazy var mRightAdd = JTHamburgerButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30)).apply({
        $0.lineColor = Style.Colors.darkGrey
        $0.lineSpacing = 4.scaled
        $0.lineWidth = 21.scaled
        $0.lineHeight = 4.scaled
        $0.setCurrentModeWithAnimation(.cross, duration: 0)
    }).tap({ [weak self] in
        self?.present(AddNewWalletVC(delegate: self), animated: true, completion: nil)
    })
    
    private lazy var mLeftMenu = JTHamburgerButton(frame: CGRect(x: 0, y: 0, width: 18, height: 16)).apply({
        $0.lineColor = Style.Colors.darkGrey
        $0.lineSpacing = 4.scaled
        $0.lineWidth = 21.scaled
        $0.lineHeight = 4.scaled
    }).tap({ [weak self] in
        self?.present(AppDelegate.menu, animated: true, completion: nil)
    })
    
    private var scanMinY: CGFloat {
        return Style.Dims.bottomScan + AppDelegate.bottomGap
    }
    
    private var defaultCatchBlock: (String)->Void {
        return { [weak self] qr in
            DispatchQueue.main.async {
                self?.show(qr: qr)
            }
        }
    }
    
    private lazy var mView = WalletList(frame: UIScreen.main.bounds).apply({ [weak self] v in
        v.onActive = { [weak self] w in
            self?.mActiveWallet = w
            self?.setNeedsStatusBarAppearanceUpdate()
        }
    })
    
    private var mActiveWallet: IWallet? {
        didSet {
            if mActiveWallet == nil {
                mWebRTC?.close()
                mWebRTC = nil
            }
            if let nb = navigationController?.navigationBar {
                nb.transform = CGAffineTransform(translationX: 0, y: mActiveWallet == nil ? 0 : -(nb.height + AppDelegate.statusHeight))
            }
            refreshLayout()
        }
    }
    
    private let mPasscode: String
        
    init(profile: Profile, passcode: String, params: String?) {
        mPasscode = passcode
        mProfile  = profile
        mParams   = params
        super.init(nibName: nil, bundle: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(close), name: UIApplication.didEnterBackgroundNotification, object: nil)
        mView.wallets = mProfile.wallets
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: mRightAdd)
        navigationItem.leftBarButtonItem  = UIBarButtonItem(customView: mLeftMenu)
        view.backgroundColor = Style.Colors.white
        view.addSubview(mView)
        view.addSubview(mScan)
    }
    
    override func sideMenuDidAppear(animated: Bool) {
        mLeftMenu.setCurrentModeWithAnimation(.arrow)
    }
    
    override func sideMenuDidDisappear(animated: Bool) {
        mLeftMenu.setCurrentModeWithAnimation(.hamburger)
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
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        mView.frame = view.bounds
        refreshLayout()

        let t = mScan.transform
        mScan.transform = .identity
        mScan.frame = CGRect(x: 0, y: view.height - scanMinY, width: view.width, height: Style.Dims.bottomScan + AppDelegate.bottomGap)
        mScan.transform = t
    }
    
    private func startScanning() {
        guard let a = mActiveWallet else { return }
        let vc = ScannerVC()
        vc.onFound = { [weak self, weak vc] json in
            guard let s = self else { return }
            if let address = a.isValid(address: json) {
                vc?.stop()
                vc?.dismiss(animated: true, completion: nil)
                s.present(SendVC(wallet: a, to: address), animated: true, completion: nil)
            } else if s.parse(request: json.trimmingCharacters(in: .whitespacesAndNewlines), supportRTC: true, block: s.defaultCatchBlock) == true {
                vc?.stop()
                vc?.dismiss(animated: true, completion: nil)
            }
        }
        present(vc, animated: true, completion: nil)
    }
    
    private func showMore(for wallet: IWallet) {
        present(MoreVC(passcode: mPasscode, wallet: wallet).apply({ [weak self] in
            $0.onDelete = { [weak self] wallet in
                self?.sureDelete(wallet: wallet)
            }
        }), animated: true, completion: nil)
    }

    private func webrtcLogin(json: String) -> Bool {
        guard let w = mActiveWallet else { return false }
        guard let obj = ApiWebRTC.deserialize(from: json) else { return false }
        guard let sid = obj.sid, let str = obj.url, let url = URL(string: str) else { return false }
        mWebRTC?.close()
        mWebRTC = RTC(wallet: w, url: url, sid: sid, delegate: self)
        mWebRTC?.connect()
        return true
    }
    
    private func show(qr text: String, share: Bool = false) {
        guard var qr = QRCode(text) else { return }
        qr.size = CGSize(width: 300, height: 300)
        let vc = AlertVC(view: AlertImage(image: qr.image), arrow: true)
        if share {
            vc.put("share".loc) { _ in
                AppDelegate.share(image: qr.image, text: text)
            }
        } else {
            vc.put("ok".loc)
        }
        vc.show()
    }
        
    private func sureDelete(wallet: IWallet) {
        present(CheckCodeVC(passcode: mPasscode, authAtStart: true, onSuccess: { [weak self] vc in
            vc.dismiss(animated: true, completion: { [weak self] in
                if let s = self {
                    s.mView.close {
                        s.mProfile.wallets.removeAll(where: { $0.id == wallet.id })
                        Settings.profile = s.mProfile
                        s.mView.delete(wallet: wallet)
                    }
                }
            })
        }).apply({
            $0.hintText = "confirm_hint".loc
        }).inNC, animated: true, completion: nil)
    }
    
    @objc private func close() {
        mWebRTC?.close()
        mWebRTC = nil
        PopupVC.hideAll()
        dismiss(animated: false, completion: nil)
        present(CheckCodeVC(passcode: mPasscode,
                            forceHide: true,
                            onSuccess: { vc in vc.dismiss(animated: true, completion: nil) }).inNC,
                animated: false,
                completion: nil)
    }

    // MARK: - Signer methods
    // -------------------------------------------------------------------------
    @discardableResult
    func parse(request: String, supportRTC: Bool, block: @escaping (String)->Void) -> Bool {
        let parts = request.split(separator: "|", maxSplits: 2, omittingEmptySubsequences: false)
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
        guard p.wallet?.blockchain.lowercased() == w.blockchain.rawValue.lowercased() else { return false }
        guard w.address == p.wallet?.address else { return false }
        DispatchQueue.main.async {
            self.present(ConfirmContractCall(contract: p, wallet: w, passcode: self.mPasscode, completion: { [weak self] signed in
                if let s = signed {
                    self?.dismiss(animated: true, completion: nil)
                    completion("|\(id)|\(s)")
                } else {
                    AlertVC("cant_signed".loc).show()
                }
            }), animated: true, completion: nil)
        }
        return true
    }
    
    @discardableResult
    func payToAddress(json: String, id: Int, completion: @escaping (String)->Void) -> Bool {
        guard let c = ApiParamsTx.deserialize(from: json) else { return false }
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
    
    private func pay(c: ApiParamsTx, from: IWallet, json: String, id: Int, completion: @escaping (String)->Void) {
        self.present(ConfirmationVC(to: from.getTo(tx: c), amount: from.getAmount(tx: c), onConfirm: { [weak self] in
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
                        AlertVC("Can't pay").show()
                    }
                })
            })
        }), animated: true, completion: nil)
    }
    
    @discardableResult
    func getWalletList(json: String, id: Int, completion: @escaping (String)->Void) -> Bool {
        guard let w = mActiveWallet else { return false }
        guard let s = [ApiParamsWallet(b: w.blockchain.rawValue.lowercased(),
                                       a: w.address,
                                       c: w.chain)].toJSONString() else { return false }
        completion("|\(id)|\(s)")
        return true
    }
    
    @discardableResult
    func signTransferTx(json: String, id: Int, completion: @escaping (String)->Void) -> Bool {
        guard let w = mActiveWallet else { return false }
        guard let t = ApiSignTransferTx.deserialize(from: json) else { return false }
        guard let p = t.wallet, let to = t.tx else { return false }
        guard t.wallet?.blockchain.lowercased() == w.blockchain.rawValue.lowercased() else { return false }
        guard w.address == t.wallet?.address else { return false }
        DispatchQueue.main.async {
            self.present(ConfirmationVC(to: w.getTo(tx: to), amount: w.getAmount(tx: to), onConfirm: { [weak self] in
                self?.dismiss(animated: true, completion: nil)
                w.sign(transaction: to, wallet: p, completion: { tx in
                    if let tx = tx {
                        completion("|\(id)|\(tx)")
                    }
                })
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
    
    func onNew(wallet: IWallet) {
        mProfile.addWallet(wallet: wallet)
        Settings.profile = mProfile
        mView.add(wallet: wallet)
    }
    
}
