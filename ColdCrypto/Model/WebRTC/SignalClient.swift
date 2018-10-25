//
//  SignalClient.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 24/10/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import Foundation
import Starscream
import WebRTC

protocol SignalClientDelegate: class {
    func signalClientDidConnect(_ signalClient: SignalClient)
    func signalClientDidDisconnect(_ signalClient: SignalClient)
    func signalClient(_ client: SignalClient, receive: String)
}

class SignalClient : WebSocketDelegate {

    private let socket: WebSocket
    weak var delegate: SignalClientDelegate?
    
    init(url: URL) {
        socket = WebSocket(url: url)
    }
    
    func connect() {
        socket.delegate = self
        socket.connect()
    }
    
    func close() {
        socket.disconnect()
    }
    
    func send(json: String) {
        socket.write(data: json.toData())
    }
    
    func websocketDidConnect(socket: WebSocketClient) {
        self.delegate?.signalClientDidConnect(self)
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        self.delegate?.signalClientDidDisconnect(self)
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        delegate?.signalClient(self, receive: text)
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {}
    
}
