//
//  Key.swift
//  SwiftyEOS
//
//  Created by croath on 2018/5/8.
//  Copyright © 2018 ProChain. All rights reserved.
//

import Foundation

func generateRandomKeyPair(enclave: SecureEnclave) -> (privateKey: PrivateKey2?, publicKey: PublicKey2?) {
    let privateKey = PrivateKey2.randomPrivateKey(enclave: enclave)
    let publicKey = PublicKey2(privateKey: privateKey!)
    
    return (privateKey, publicKey)
}

func generateRandomKeyPair() -> (privateKey: PrivateKey2?, publicKey: PublicKey2?, mnemonic: String?) {
    let (privateKey, mnemonic) = PrivateKey2.randomPrivateKeyAndMnemonic()
    let publicKey = PublicKey2(privateKey: privateKey!)
    
    return (privateKey, publicKey, mnemonic)
}
