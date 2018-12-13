//
//  RTC.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 24/10/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import Foundation
import WebRTC

class RTC: NSObject, SignalClientDelegate, WebRTCClientDelegate, RTCDataChannelDelegate {
        
    private let signalClient: SignalClient
    private var webRTCClient = WebRTCClient(servers: [ApiIceServer().apply({
        $0.urls = ["stun:stun.l.google.com:19302"]
    })])
    
    private let mSID: String
    
    private weak var mDelegate: Signer?
    
    private var mChannel: RTCDataChannel?
    
    let wallet: IWallet
    
    init(wallet: IWallet, url: URL, sid: String, delegate: Signer) {
        mSID = sid
        self.wallet = wallet
        mDelegate = delegate
        signalClient = SignalClient(url: url)
    }
    
    func connect() {
        webRTCClient.delegate = self
        signalClient.delegate = self
        wallet.connectionStatus = .start
        signalClient.connect()
    }
    
    func close() {
        mChannel?.delegate = nil
        mChannel?.close()
        
        webRTCClient.delegate = nil
        webRTCClient.close()
        
        signalClient.delegate = nil
        signalClient.close()
        
        wallet.connectionStatus = .stop
    }
    
    private func received(offer: String) {
        webRTCClient.set(remoteSdp: RTCSessionDescription(type: RTCSdpType.offer, sdp: offer)) { (error) in
            if let e = error {
                print("set remote sdp error = \(e)")
                return
            }
            self.webRTCClient.answer(completion: { (answer) in
                self.signalClient.send(json: ApiAnswer(answer: answer.sdp).full())
            })
        }
    }
    
    // MARK: - SignalClientDelegate methods
    // -------------------------------------------------------------------------
    func signalClientDidConnect(_ signalClient: SignalClient) {
        signalClient.send(json: ApiJoin(sid: mSID).full())
    }
    
    func signalClient(_ client: SignalClient, receive: String) {
        let parts = receive.split(separator: "|", maxSplits: 2, omittingEmptySubsequences: false)
        if parts.count >= 3, parts[0] == "" && Int(parts[1]) == ApiJoin.id,
            let offer = ApiOffer.deserialize(from: String(parts[2])), let str = offer.offer {
            DispatchQueue.main.async {
                self.received(offer: str)
            }
            return
        }
        if parts.count >= 3, parts[0] == ApiIce.method,
            let ice = ApiIce.deserialize(from: String(parts[2]))?.ice {
            DispatchQueue.main.async {
                self.webRTCClient.set(remoteCandidate: RTCIceCandidate(sdp: ice.candidate,
                                                                       sdpMLineIndex: Int32(ice.sdpMLineIndex),
                                                                       sdpMid: ice.sdpMid))
            }
        }
        if parts.count >= 3, parts[0] == ApiIceServer.method,
            let servers = [ApiIceServer].deserialize(from: String(parts[2])) {
            DispatchQueue.main.async {
                self.webRTCClient.delegate = nil
                self.webRTCClient.close()
                self.webRTCClient = WebRTCClient(servers: servers.compactMap({ $0 }))
                self.webRTCClient.delegate = self
            }
            return
        }
        if parts.count >= 3, parts[0] == ApiFallback.method, let obj = ApiFallback.deserialize(from: String(parts[2]))?.msg {
            DispatchQueue.main.async {
                self.mDelegate?.parse(request: obj, supportRTC: false, block: { [weak client] send in
                    let json = ApiFallback().apply({
                        $0.msg = send
                    }).toJSONString() ?? ""
                    client?.send(json: ApiFallback.method+"|"+parts[1]+"|"+json)
                })
            }
            return
        }
        DispatchQueue.main.async {
            self.mDelegate?.parse(request: receive, supportRTC: false, block: { [weak client] send in
                client?.send(json: send)
            })
        }
    }
    
    func signalClientDidDisconnect(_ signalClient: SignalClient) {}
    
    // MARK: - WebRTCClientDelegate methods
    // -------------------------------------------------------------------------
    func webRTCClient(_ client: WebRTCClient, didChange newState: RTCIceConnectionState) {
        DispatchQueue.main.async {
            if newState == .closed || newState == .disconnected || newState == .failed {
                self.wallet.connectionStatus = .stop
            } else if newState == .completed || newState == .connected {
                self.wallet.connectionStatus = .success
            }
        }
    }
    
    func webRTCClient(_ client: WebRTCClient, didDiscoverLocalCandidate candidate: RTCIceCandidate) {
        DispatchQueue.main.async {
            self.signalClient.send(json: ApiIce(candidate: candidate.sdp,
                                                sdpMLineIndex: Int(candidate.sdpMLineIndex),
                                                sdpMid: candidate.sdpMid ?? "").full())
        }
    }
    
    func webRTCClient(_ client: WebRTCClient, didOpenChannel channel: RTCDataChannel) {
        DispatchQueue.main.async {
            self.mChannel = channel
            self.mChannel?.delegate = self
        }
    }
    
    // MARK: - RTCDataChannelDelegate methods
    // -------------------------------------------------------------------------
    func dataChannelDidChangeState(_ dataChannel: RTCDataChannel) {}
    
    func dataChannel(_ dataChannel: RTCDataChannel, didReceiveMessageWith buffer: RTCDataBuffer) {
        if let request = String(data: buffer.data, encoding: String.Encoding.utf8) {
            DispatchQueue.main.async {
                self.mDelegate?.parse(request: request, supportRTC: false, block: { [weak dataChannel] send in
                    dataChannel?.sendData(RTCDataBuffer(data: send.toData(), isBinary: false))
                })
            }
        }
    }
    
}
