//
//  Settings.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 20/10/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import UIKit
import KeychainAccess

class Settings {
    
    private static let keychain = Keychain(service: "multimask.settings")
    
    static func clear() {
        try? keychain.removeAll()
    }
    
    static var isFirstStart: Bool {
        get {
            if UserDefaults.standard.object(forKey: "isFirstStart") != nil {
                return UserDefaults.standard.bool(forKey: "isFirstStart")
            }
            return true
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "isFirstStart")
            UserDefaults.standard.synchronize()
        }
    }
    
    static var profile: Profile? {
        get {
            do {
                let data = try keychain.getData("wallet")
                guard let d = data else { return nil }
                guard let j = try? JSONSerialization.jsonObject(with: d, options: []) else { return nil }
                return Profile(json: j as? [String: Any])
            } catch let e {
                print("\(e)")
            }
            return nil
        }
        set {
            if let json = newValue?.getJson(), let info = try? JSONSerialization.data(withJSONObject: json, options: []) {
                try? keychain.set(info, key: "wallet")
            } else {
                try? keychain.remove("wallet")
            }
        }
    }
    
    static var useBio: Bool? {
        get {
            return keychain["useBio"] == nil ? nil : keychain["useBio"] == "true"
        }
        set {
            keychain["useBio"] = (newValue == nil ? nil : (newValue == true ? "true" : "false"))
        }
    }
    
    static var passcode: String? {
        get {
            return keychain["passcode"]
        }
        set {
            if (newValue?.count ?? 0) == 0 {
                try? keychain.remove("passcode")
            } else {
                keychain["passcode"] = newValue
            }
        }
    }
    
}
