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
    
    static func getTransactions2(network: INetwork, account: String, completion: @escaping ([ITransaction]?)->Void) {
        guard let n = network as? Blockchain.Network.EOS else {
            completion([])
            return
        }
        
        var base: String
        switch n {
        case .Jungle:  base = "https://junglehistory.cryptolions.io"
        case .MainNet: base = n.node
        }

        guard let url = URL(string: "\(base)/v1/history/get_actions") else {
            completion([])
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = "{\"pos\":-1, \"offset\": -1000, \"account_name\": \"\(account)\"}".toData()
        
        let session = URLSession(configuration: URLSessionConfiguration.default)
        session.dataTask(with: request, completionHandler: { data, response, error in
            DispatchQueue.global().async {
                let actions: EOSActions? = data?.convert()
                var result: [EOSTransaction]?
                
                var cache: [String: Bool] = [:]
                actions?.actions?.compactMap({ $0.action_trace }).forEach({ t in
                    if let id = t.trx_id, cache[id] == nil, let d = t.act?.data, d.quantity != nil {
                        cache[id] = true
                        d.id = t.trx_id
                        d.time = t.block_time
                        
                        if result == nil {
                            result = [EOSTransaction]()
                        }
                        
                        result?.insert(EOSTransaction(account: account, source: d, network: network), at: 0)
                    }
                })
                DispatchQueue.main.async {
                    completion(result)
                }
            }
        }).resume()
    }
    
}
