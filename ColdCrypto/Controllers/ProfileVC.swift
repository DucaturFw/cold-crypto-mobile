//
//  ViewController.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 18/10/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import QRCode
import UIKit

class ProfileVC: UIViewController, ImportDelegate, ISignerDelegate {

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
    
    private lazy var mSigner = Signer(delegate: self)
    
    private var mActiveWallet: IWallet? {
        didSet {
            mSigner.activeWallet = mActiveWallet
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
            mSigner.parse(request: p, supportRTC: true, block: defaultCatchBlock)
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
            let value = json.trimmingCharacters(in: .whitespacesAndNewlines)
            if let address = a.isValid(address: value) {
                vc?.stop()
                vc?.dismiss(animated: true, completion: nil)
                s.present(SendVC(wallet: a, to: address), animated: true, completion: nil)
            } else if s.mSigner.parse(request: value, supportRTC: true, block: s.defaultCatchBlock) {
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
        mSigner.closeRTC()
        PopupVC.hideAll()
        dismiss(animated: false, completion: nil)
        present(CheckCodeVC(passcode: mPasscode,
                            forceHide: true,
                            onSuccess: { vc in vc.dismiss(animated: true, completion: nil) }).inNC,
                animated: false,
                completion: nil)
    }

    // MARK: - ImportDelegate methods
    // -------------------------------------------------------------------------
    func onNew(chain: Blockchain, name: String, data: String, segwit: Bool, network: INetwork) {
        guard let w = mProfile.newWallet(chain: chain,
                                         name: name,
                                         data: data,
                                         segwit: segwit,
                                         network: network) else { return }
        Settings.profile = mProfile
        mView.add(wallet: w)
    }
    
    func onNewHDWallet(chain: Blockchain, network: INetwork) {
        guard let w = mProfile.newWallet(chain: chain,
                                         name: "",
                                         data: String(format: "02%02x", mProfile.index + 1),
                                         segwit: false,
                                         network: network) else { return }
        mProfile.index += 1
        Settings.profile = mProfile
        mView.add(wallet: w)
    }
    
    func onNew(wallet: IWallet) {
        mProfile.addWallet(wallet: wallet)
        Settings.profile = mProfile
        mView.add(wallet: wallet)
    }
    
    // MARK:-
    // -------------------------------------------------------------------------
    func confirm(contract: ApiSignContractCall, wallet: IWallet, from: Signer, success: @escaping (String) -> Void) {
        present(ConfirmContractCall(contract: contract, wallet: wallet, passcode: mPasscode, completion: { [weak self] signed in
            if let s = signed {
                if let me = self {
                    me.dismiss(animated: true, completion: {
                        success(s)
                    })
                } else {
                    success(s)
                }
            } else {
                AlertVC("cant_signed".loc).show()
            }
        }), animated: true, completion: nil)
    }
    
    func confirm(to: String, amount: String, success: @escaping ()->Void) {
        present(ConfirmationVC(to: to, amount: amount, onConfirm: { [weak self] in
            if let me = self {
                me.dismiss(animated: true, completion: success)
            } else {
                success()
            }
        }), animated: true, completion: nil)
    }
    
}
