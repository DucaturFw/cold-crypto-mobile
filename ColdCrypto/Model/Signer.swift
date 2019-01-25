//
//  Signer.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 24/10/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import Foundation

protocol ISignerDelegate: class {
    func confirm(contract: ApiSignContractCall, wallet: IWallet, from: Signer, success: @escaping (String)->Void)
    func confirm(to: String, amount: String, success: @escaping ()->Void)
}

class Signer: ISigner {
    
    private var mWebRTC: RTC? = nil
    
    var activeWallet: IWallet? {
        didSet {
            if activeWallet == nil {
                closeRTC()
            }
        }
    }
    
    private weak var mDelegate: ISignerDelegate?
    
    init(delegate: ISignerDelegate) {
        mDelegate = delegate
    }
    
    func closeRTC() {
        mWebRTC?.close()
        mWebRTC = nil
    }
    
    @discardableResult
    func parse(request: String, supportRTC: Bool, block: @escaping (String)->Void) -> Bool {
        let parts = request.split(separator: "|", maxSplits: 2, omittingEmptySubsequences: false)
        var catched: Bool = false
        if parts.count > 2, let id = Int(parts[1]) {
            let json = String(parts[2])
            switch parts[0] {
            case "payToAddress": catched = payToAddress(json: json, id: id, completion: block)
            case "signTransferTx": catched = signTransferTx(json: json, id: id, completion: block)
            case "getWalletList": catched = getWalletList(json: json, id: id, completion: block)
            case "webrtcLogin": if supportRTC { catched = webrtcLogin(json: json) }
            case "signContractCall": catched = signContractCall(json: json, id: id, completion: block)
            case "getVersion": catched = getVersion(json: json, id: id, completion: block)
            default: catched = false
            }
        }
        return catched
    }
    
    private func webrtcLogin(json: String) -> Bool {
        guard let w = activeWallet else { return false }
        guard let obj = ApiWebRTC.deserialize(from: json) else { return false }
        guard let sid = obj.sid, let str = obj.url, let url = URL(string: str) else { return false }
        mWebRTC?.close()
        mWebRTC = RTC(wallet: w, url: url, sid: sid, delegate: self)
        mWebRTC?.connect()
        return true
    }
    
    @discardableResult
    func getVersion(json: String, id: Int, completion: @escaping (String)->Void) -> Bool {
        DispatchQueue.main.async {
            completion("|\(id)|\"v0.1i\"")
        }
        return true
    }
    
    @discardableResult
    func signContractCall(json: String, id: Int, completion: @escaping (String)->Void) -> Bool {
        guard let w = activeWallet else { return false }
        guard let p = ApiSignContractCall.deserialize(from: json) else { return false }
        guard p.wallet?.blockchain.lowercased() == w.blockchain.rawValue.lowercased() else { return false }
        guard w.address == p.wallet?.address else { return false }
        DispatchQueue.main.async {
            self.mDelegate?.confirm(contract: p, wallet: w, from: self, success: { signed in
                completion("|\(id)|\(signed)")
            })
        }
        return true
    }
    
    @discardableResult
    func payToAddress(json: String, id: Int, completion: @escaping (String)->Void) -> Bool {
        // TODO: need to rework this logic! i.e. user should be able to select card if it's not selected
        guard let w = activeWallet else { return false }
        guard let c = ApiParamsTx.deserialize(from: json) else { return false }
        guard w.blockchain.rawValue == c.blockchain?.uppercased() else { return false }
        DispatchQueue.main.async {
            self.pay(c: c, from: w, json: json, id: id, completion: completion)
        }
        return true
    }
    
    private func pay(c: ApiParamsTx, from: IWallet, json: String, id: Int, completion: @escaping (String)->Void) {
        mDelegate?.confirm(to: from.getTo(tx: c), amount: from.getAmount(tx: c), success: {
            let hud = AppDelegate.hud()
            from.pay(to: c, completion: { txHash in
                hud?.hide(animated: true)
                if let tx = txHash {
                    if let callback = c.callback, let url = URL(string: callback) {
                        UIApplication.shared.open(url.append("txHash", value: tx), options: [:], completionHandler: nil)
                    } else {
                        completion("|\(id)|\"\(tx)\"")
                    }
                } else {
                    AlertVC("Can't pay").show()
                }
            })
        })
    }
    
    @discardableResult
    func getWalletList(json: String, id: Int, completion: @escaping (String)->Void) -> Bool {
        guard let w = activeWallet else { return false }
        guard let s = [ApiParamsWallet(b: w.blockchain.rawValue.lowercased(),
                                       a: w.address,
                                       c: w.chain)].toJSONString() else { return false }
        completion("|\(id)|\(s)")
        return true
    }
    
    @discardableResult
    func signTransferTx(json: String, id: Int, completion: @escaping (String)->Void) -> Bool {
        guard let w = activeWallet else { return false }
        guard let t = ApiSignTransferTx.deserialize(from: json) else { return false }
        guard let p = t.wallet, let to = t.tx else { return false }
        guard t.wallet?.blockchain.lowercased() == w.blockchain.rawValue.lowercased() else { return false }
        guard t.wallet?.chainId == w.chain else { return false }
        guard w.address == t.wallet?.address else { return false }
        DispatchQueue.main.async {
            self.mDelegate?.confirm(to: w.getTo(tx: to), amount: w.getAmount(tx: to), success: {
                w.sign(transaction: to, wallet: p, completion: { tx in
                    if let tx = tx {
                        completion("|\(id)|\(tx)")
                    }
                })
            })
        }
        return true
    }
    
}
