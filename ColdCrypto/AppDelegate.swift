//
//  AppDelegate.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 18/10/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)

        Settings.profile = nil
        Settings.useBio  = nil
        
        if let code = Settings.passcode, let p = Settings.profile {
            let nc = UINavigationController()
            nc.viewControllers = [CheckCodeVC(passcode: code, style: .normal, onSuccess: { vc in
                vc.navigationController?.setViewControllers([ViewController(profile: p)], animated: true)
            })]
            window?.rootViewController = nc
        } else {
            window?.rootViewController = UINavigationController(rootViewController: AuthVC())
        }
        window?.makeKeyAndVisible()
        return true
    }

}
