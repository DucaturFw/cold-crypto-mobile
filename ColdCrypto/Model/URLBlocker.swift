//
//  URLBlocker.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 26/05/2019.
//  Copyright © 2019 Kirill Kozhuhar. All rights reserved.
//

import Foundation
class GuardURLProtocol: URLProtocol, URLSessionDataDelegate {
    
    fileprivate var connection: NSURLConnection? = nil
    
    fileprivate var _task: URLSessionTask? = nil
    override var task: URLSessionTask? {
        get {
            return _task
        }
        set {
            _task = newValue
        }
    }
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canInit(with task: URLSessionTask) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        if shouldBlockRequest() {
            let error = NSError(domain: "GuardURLProtocol", code: 10, userInfo: [NSLocalizedDescriptionKey: "Connection denied by guard"])
            self.client?.urlProtocol(self, didFailWithError: error)
        } else if let task = self.task {
            task.resume()
        } else {
            let session = URLSession(configuration: .default, delegate: self, delegateQueue: URLSession.shared.delegateQueue)
            let t = session.dataTask(with: self.request) { (d: Data?, r: URLResponse?, e: Error?) in
                if let e = e {
                    self.client?.urlProtocol(self, didFailWithError: e)
                } else {
                    if let r = r {
                        self.client?.urlProtocol(self, didReceive: r, cacheStoragePolicy: .allowed)
                    }
                    if let d = d {
                        self.client?.urlProtocol(self, didLoad: d)
                    }
                    self.client?.urlProtocolDidFinishLoading(self)
                }
            }
            t.resume()
            task = t
        }
    }
    
    override func stopLoading() {
        self.task?.cancel()
    }
    
    public func shouldBlockRequest() -> Bool {
        return false
    }
}

class BlockURLProtocol: GuardURLProtocol {
    static var blocked = false
    override func shouldBlockRequest() -> Bool {
        return BlockURLProtocol.blocked
    }
}

fileprivate let mSharedSession: URLSession = {
    let configuration = URLSessionConfiguration.default
    configuration.protocolClasses = [BlockURLProtocol.self]
    return URLSession(configuration:configuration)
}()

extension URLSession {
    static var common: URLSession {
        return mSharedSession
        //        return URLSession.shared
    }
}
