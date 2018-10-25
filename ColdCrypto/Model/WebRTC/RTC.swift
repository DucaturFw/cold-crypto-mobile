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
    private let webRTCClient = WebRTCClient()
    
    private let mSID: String
    
    private weak var mDelegate: Signer?
    
    private var mChannel: RTCDataChannel?
    
    init(url: URL, sid: String, delegate: Signer) {
        mSID = sid
        mDelegate = delegate
        signalClient = SignalClient(url: url)
    }
    
    func connect() {
        webRTCClient.delegate = self
        signalClient.delegate = self
        signalClient.connect()
    }
    
    func close() {
        mChannel?.delegate = nil
        mChannel?.close()
        
        webRTCClient.delegate = nil
        webRTCClient.close()
        
        signalClient.delegate = nil
        signalClient.close()
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
        print("connected. sending = \(ApiJoin(sid: mSID).full())")
        signalClient.send(json: ApiJoin(sid: mSID).full())
    }
    
    func signalClient(_ client: SignalClient, receive: String) {
        
        print("receive = \(receive)")
        
        let parts = receive.split(separator: "|", maxSplits: Int.max, omittingEmptySubsequences: false)
        
//        print("\(parts.count)")
        
        if parts.count >= 3, parts[0] == "" && Int(parts[1]) == ApiJoin.id,
            let offer = ApiOffer.deserialize(from: String(parts[2])), let str = offer.offer {
            received(offer: str)
        } else if parts.count >= 3, parts[0] == ApiIce.method,
            let ice = ApiIce.deserialize(from: String(parts[2]))?.ice {
            webRTCClient.set(remoteCandidate: RTCIceCandidate(sdp: ice.candidate,
                                                              sdpMLineIndex: Int32(ice.sdpMLineIndex),
                                                              sdpMid: ice.sdpMid))
        }
    }
    
    func signalClientDidDisconnect(_ signalClient: SignalClient) {
        print("signaling disconnected")
    }
    
    // MARK: - WebRTCClientDelegate methods
    // -------------------------------------------------------------------------
    func webRTCClient(_ client: WebRTCClient, didDiscoverLocalCandidate candidate: RTCIceCandidate) {
        signalClient.send(json: ApiIce(candidate: candidate.sdp,
                                       sdpMLineIndex: Int(candidate.sdpMLineIndex),
                                       sdpMid: candidate.sdpMid ?? "").full())
    }
    
    func webRTCClient(_ client: WebRTCClient, didOpenChannel channel: RTCDataChannel) {
        mChannel = channel
        mChannel?.delegate = self
    }
    
    // MARK: - RTCDataChannelDelegate methods
    // -------------------------------------------------------------------------
    func dataChannelDidChangeState(_ dataChannel: RTCDataChannel) {}
    
    func dataChannel(_ dataChannel: RTCDataChannel, didReceiveMessageWith buffer: RTCDataBuffer) {
        if let request = String(data: buffer.data, encoding: String.Encoding.utf8) {
            print("request = \(request)")
            DispatchQueue.main.async {
                self.mDelegate?.parse(request: request, supportRTC: false, block: { [weak dataChannel] send in
                    
                    print("send to server = \(send)")
                    
                    dataChannel?.sendData(RTCDataBuffer(data: send.toData(), isBinary: false))
                })
            }
        }
    }
    
}
