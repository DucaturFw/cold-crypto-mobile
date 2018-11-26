//
//  EOSUtils.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 26/11/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import Foundation
import JavaScriptCore

class EOSUtils {
    
    private static let mInstance = EOSUtils()
    
    private let context = JSContext()
    
    private init() {
        let consoleLog: @convention(block) (String)->() = { s in print("JS log: "+s) }
        let console = context?.objectForKeyedSubscript("console")
        console?.setObject(unsafeBitCast(consoleLog, to: AnyObject.self), forKeyedSubscript: "log" as NSString)
        
        if let file = Bundle.main.path(forResource: "eos.js", ofType: nil) {
            do {
                let common = try String(contentsOfFile: file, encoding: String.Encoding.utf8)
                _ = context?.evaluateScript(common)
            } catch (let error) {
                print("Error while processing script file: \(error)")
            }
        }
    }

    static func call(js: String, result callback: @escaping (String?)->Void) -> JSValue? {
        return mInstance.call(js: js, result: callback)
    }
    
    func call(js: String, result callback: @escaping (String?)->Void) -> JSValue? {
        let consoleLog: @convention(block) (String)->() = { s in callback(s) }
        let console = context?.objectForKeyedSubscript("console")
        console?.setObject(unsafeBitCast(consoleLog, to: AnyObject.self), forKeyedSubscript: "ios" as NSString)
        return context?.evaluateScript(js)
    }
    
}
