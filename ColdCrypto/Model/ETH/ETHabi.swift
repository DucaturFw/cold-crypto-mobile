//
//  ETHabi.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 21/11/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import Foundation
import JavaScriptCore

class ETHabi {
   
    private static let mInstance = ETHabi()
    
    private let context = JSContext()
    
    private init() {
        let consoleLog: @convention(block) (String)->() = { s in print(s) }
        let console = context?.objectForKeyedSubscript("console")
        console?.setObject(unsafeBitCast(consoleLog, to: AnyObject.self), forKeyedSubscript: "log" as NSString)
        if let file = Bundle.main.path(forResource: "abi.js", ofType: nil) {
            do {
                let common = try String(contentsOfFile: file, encoding: String.Encoding.utf8)
                _ = context?.evaluateScript(common)
            } catch (let error) {
                print("Error while processing script file: \(error)")
            }
        }
    }
    
    static func convert(call: String, data: String) -> String? {
        return mInstance.call(js: "script.parse(\"\(call)\", \"\(data)\")")?.toString()
    }
    
    private func call(js: String) -> JSValue? {
        return context?.evaluateScript(js)
    }
    
}
