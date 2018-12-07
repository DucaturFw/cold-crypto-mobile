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
import EthereumKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    public static var version: String? {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }
    
    public static var build: String? {
        return Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String
    }
    
    public static var bottomGap: CGFloat {
        return UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0
    }
    
    public static var statusHeight: CGFloat {
        return UIApplication.shared.statusBarFrame.size.height
    }
    
    static let menu = UISideMenuNavigationController(rootViewController: MenuVC())
    
    var window: UIWindow?

    static var params: String? = nil
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        BITHockeyManager.shared().configure(withIdentifier: "fd96c74c233a4c328c2d4f7df741ab9a")
        BITHockeyManager.shared().start()
        BITHockeyManager.shared().authenticator.authenticateInstallation()
        
        if Settings.isFirstStart {
            Settings.isFirstStart = false
            Settings.clear()
        }
        
        EOSRPC.endpoint = "http://jungle.eosgen.io:80"
                
        SideMenuManager.default.menuLeftNavigationController = AppDelegate.menu
        SideMenuManager.default.menuFadeStatusBar = false
        
        UINavigationBar.appearance().shadowImage   = UIImage()
        UINavigationBar.appearance().isTranslucent = true
        UINavigationBar.appearance().barTintColor  = Style.Colors.white
        UINavigationBar.appearance().titleTextAttributes = [
            .font : UIFont.medium(18.scaled),
            .foregroundColor: Style.Colors.black
        ]
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor     = .white
        window?.layer.cornerRadius  = 10.scaled
        window?.layer.masksToBounds = true
        window?.rootViewController  = NavigatorVC(rootViewController: AuthVC())
        window?.makeKeyAndVisible()
                
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
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
    
    private static let mQueue = DispatchQueue(label: "lock")
    private static var mLock  = 0
    
    static func lock() {
        mQueue.sync {
            if mLock == 0 {
                UIApplication.shared.beginIgnoringInteractionEvents()
            }
            mLock += 1
        }
    }
    
    static func unlock() {
        mQueue.sync {
            if mLock > 0 {
                mLock -= 1
                if mLock == 0 {
                    UIApplication.shared.endIgnoringInteractionEvents()
                }
            }
        }
        
    }
    
    static func share(image: UIImage?, text: String) {
        DispatchQueue.main.async {
            var shareItems: [Any] = [text]
            if let i = image {
                shareItems.append(i)
            }
            let vc = (UIApplication.shared.delegate as? AppDelegate)?.window?.rootViewController
            vc?.present(UIActivityViewController(activityItems: shareItems,
                                                 applicationActivities: nil),
                        animated: true,
                        completion: nil)
        }
    }

}
