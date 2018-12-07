//
//  WebRTCClient.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 24/10/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import Foundation
import WebRTC

protocol WebRTCClientDelegate: class {
    func webRTCClient(_ client: WebRTCClient, didDiscoverLocalCandidate candidate: RTCIceCandidate)
    func webRTCClient(_ client: WebRTCClient, didOpenChannel channel: RTCDataChannel)
    func webRTCClient(_ client: WebRTCClient, didChange newState: RTCIceConnectionState)
}

class WebRTCClient: NSObject {
    private let factory = RTCPeerConnectionFactory()
    
    let peerConnection: RTCPeerConnection
    weak var delegate: WebRTCClientDelegate?
    var localCandidates = [RTCIceCandidate]()
    
    private static let constraints = RTCMediaConstraints(mandatoryConstraints: nil, optionalConstraints: nil)
    
    init(servers: [ApiIceServer]) {
        let config = RTCConfiguration()
        let mapped: [RTCIceServer] = servers.compactMap({
            if let urls = $0.urls,
                let username = $0.username,
                let credentials = $0.credential,
                username.count > 0 && credentials.count > 0 {
                return RTCIceServer(urlStrings: urls, username: username, credential: credentials)
            } else if let urls = $0.urls {
                return RTCIceServer(urlStrings: urls)
            }
            return nil
        })
        config.iceServers = mapped
        config.sdpSemantics = .unifiedPlan
        config.continualGatheringPolicy = .gatherContinually

        peerConnection = factory.peerConnection(with: config,
                                                constraints: WebRTCClient.constraints,
                                                delegate: nil)
        super.init()
        peerConnection.delegate = self
    }
    
    func close() {
        peerConnection.close()
    }
    
    func offer(completion: @escaping (_ sdp: RTCSessionDescription) -> Void) {
        self.peerConnection.offer(for: WebRTCClient.constraints) { (sdp, error) in
            guard let sdp = sdp else { return }
            self.peerConnection.setLocalDescription(sdp, completionHandler: { (error) in
                completion(sdp)
            })
        }
    }
    
    func answer(completion: @escaping (_ sdp: RTCSessionDescription) -> Void)  {
        self.peerConnection.answer(for: WebRTCClient.constraints) { (sdp, error) in
            guard let sdp = sdp else { return }
            self.peerConnection.setLocalDescription(sdp, completionHandler: { (error) in
                completion(sdp)
            })
        }
    }
    
    func set(remoteSdp: RTCSessionDescription, completion: @escaping (Error?) -> ()) {
        self.peerConnection.setRemoteDescription(remoteSdp, completionHandler: completion)
    }
    
    func set(remoteCandidate: RTCIceCandidate) {
        self.peerConnection.add(remoteCandidate)
    }
    
}

extension WebRTCClient: RTCPeerConnectionDelegate {
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange stateChanged: RTCSignalingState) {
        print("peerConnection new signaling state: \(stateChanged)")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didAdd stream: RTCMediaStream) {
        print("peerConnection did add stream")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove stream: RTCMediaStream) {
        print("peerConnection did remote stream")
    }
    
    func peerConnectionShouldNegotiate(_ peerConnection: RTCPeerConnection) {
        print("peerConnection should negotiate")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceConnectionState) {
        print("peerConnection new connection state: \(newState)")
        DispatchQueue.main.async {
            self.delegate?.webRTCClient(self, didChange: newState)
        }
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceGatheringState) {
        print("peerConnection new gathering state: \(newState)")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didGenerate candidate: RTCIceCandidate) {
        localCandidates.append(candidate)
        delegate?.webRTCClient(self, didDiscoverLocalCandidate: candidate)
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove candidates: [RTCIceCandidate]) {
        print("peerConnection did remove candidates \(candidates)")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didOpen dataChannel: RTCDataChannel) {
        delegate?.webRTCClient(self, didOpenChannel: dataChannel)
    }
    
}
