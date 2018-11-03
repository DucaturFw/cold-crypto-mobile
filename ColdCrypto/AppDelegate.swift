//
//  AppDelegate.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 18/10/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import UIKit
import SideMenu
import HockeySDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    public static var version: String? {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }
    
    public static var build: String? {
        return Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String
    }
    
    static let menu = UISideMenuNavigationController(rootViewController: MenuVC())
    
    var window: UIWindow?
    
    private let mBlur: UIVisualEffectView = {
        let tmp = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
        tmp.frame = UIScreen.main.bounds
        return tmp
    }()
    
    private var mLock: CheckCodeVC?
    
    static var params: String? = nil
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        BITHockeyManager.shared().configure(withIdentifier: "fd96c74c233a4c328c2d4f7df741ab9a")
        BITHockeyManager.shared().start()
        BITHockeyManager.shared().authenticator.authenticateInstallation()
        
        if Settings.isFirstStart {
            Settings.isFirstStart = false
            Settings.clear()
        }
        
        SideMenuManager.default.menuLeftNavigationController = AppDelegate.menu
        SideMenuManager.default.menuFadeStatusBar = false
        
        UINavigationBar.appearance().shadowImage   = UIImage()
        UINavigationBar.appearance().isTranslucent = true
        UINavigationBar.appearance().barTintColor  = .white
        
        window = UIWindow(frame: UIScreen.main.bounds)
        if let code = Settings.passcode, let p = Settings.profile {
            let nc = UINavigationController()
            nc.viewControllers = [CheckCodeVC(passcode: code, style: .normal, onSuccess: { vc in
                vc.navigationController?.setViewControllers([ProfileVC(profile: p, params: AppDelegate.params)], animated: true)
            })]
            window?.rootViewController = nc
        } else {
            window?.rootViewController = UINavigationController(rootViewController: AuthVC())
        }
        window?.makeKeyAndVisible()
        return true
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        window?.endEditing(true)
        guard (window?.rootViewController as? UINavigationController)?.viewControllers.first as? ProfileVC != nil else { return }
        guard let c = Settings.passcode else { return }
        guard let _ = Settings.profile else { return }
        
        mLock?.view.removeFromSuperview()
        let vc = CheckCodeVC(passcode: c, style: .overlay, onSuccess: { [weak self] _ in
            self?.removeLock()
        })
        mLock = vc
        vc.view.frame = UIScreen.main.bounds
        vc.view.alpha = 0.0
        mBlur.contentView.addSubview(vc.view)
        window?.addSubview(mBlur)
    }
    
    private func removeLock() {
        UIView.animate(withDuration: 0.25, animations: {
            self.mBlur.alpha = 0.0
        }, completion: { _ in
            self.mBlur.removeFromSuperview()
            self.mBlur.alpha = 1.0
            self.mLock?.view.removeFromSuperview()
            self.mLock = nil
            ((self.window?.rootViewController as? UINavigationController)?.viewControllers.first as? ProfileVC)?.check(params: AppDelegate.params)
            AppDelegate.params = nil
        })
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        window?.endEditing(true)
        if mBlur.superview != nil && (mLock?.view.alpha ?? 1.0) < 1.0 {
            UIView.animate(withDuration: 0.25, animations: {
                self.mLock?.view.alpha = 1.0
            }, completion: { _ in
                self.mLock?.startBioAuth()
            })
        }
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        if let params = url.allParams["qr"] {
            AppDelegate.params = params
        }
        return true
    }
    
    static func resetWallet() {
        Settings.profile  = nil
        Settings.passcode = nil
        ((UIApplication.shared.delegate as? AppDelegate)?.window?.rootViewController as? UINavigationController)?.setViewControllers([AuthVC()], animated: true)
    }

}
