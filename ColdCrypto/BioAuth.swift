//
//  BioAuth.swift
//  MultiMask
//
//  Created by Kirill Kozhuhar on 04/08/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import Foundation
import LocalAuthentication


class BioAuth {
    
    enum AuthType {
        case none, face, touch
    }
    
    private let laContext = LAContext()
    
    private let policy = LAPolicy.deviceOwnerAuthenticationWithBiometrics
    
    var authType: AuthType {
        var error: NSError?
        if (laContext.canEvaluatePolicy(policy, error: &error)) {
            if error == nil && laContext.biometryType == .faceID {
                return .face
            } else if error == nil && laContext.biometryType == .touchID {
                return .touch
            }
        }
        return .none
    }
    
    func tryToAuthWithBio(success: @escaping (Bool)->Void) {
        var error: NSError?
        if (laContext.canEvaluatePolicy(policy, error: &error)) {
            if error == nil {
                var localizedReason: String? = nil
                if (laContext.biometryType == LABiometryType.faceID) {
                    localizedReason = "face_id".loc
                } else if (laContext.biometryType == LABiometryType.touchID) {
                    localizedReason = "touch_id".loc
                }
                if let r = localizedReason {
                    laContext.evaluatePolicy(policy, localizedReason: r, reply: { (isSuccess, error) in
                        DispatchQueue.main.async(execute: {
                            success(isSuccess)
                        })
                    })
                    return
                }
            }
            DispatchQueue.main.async {
                success(false)
            }
        } else {
            DispatchQueue.main.async {
                success(false)
            }
        }
    }
    
}
