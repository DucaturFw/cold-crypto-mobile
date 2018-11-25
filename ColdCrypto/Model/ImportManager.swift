//
//  ImportManager.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 10/11/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import Foundation
import EthereumKit

protocol ImportDelegate {
    func onNew(chain: Blockchain, name: String, data: String, segwit: Bool)
    func onNewHDWallet(chain: Blockchain)
    func onNew(wallet: IWallet)
    func setTop(visible: Bool)
}

class ImportManager {
    
    private weak var mParent: (UIViewController & ImportDelegate)?
    
    init(parent: (UIViewController & ImportDelegate)) {
        mParent = parent
    }
    
    func addNewWallet() {
        guard let p = mParent else { return }
        p.setTop(visible: false)
        ChainPicker().show(in: p, block: { [weak self, weak p] b in
            guard let p = p else { return }
            p.setTop(visible: true)
            if let b = b, b == .EOS {
                self?.importEOS()
            } else if let b = b {
                self?.askWhatToAdd(in: b)
            }
        })
    }
    
    private func importEOS() {
        guard let parent = mParent?.navigationController ?? mParent else { return }
        EOSImporter.importWallet(from: parent, completion: { [weak self] w in
            if let w = w {
                self?.mParent?.onNew(wallet: w)
            }
        })
    }
    
    private func askWhatToAdd(in chain: Blockchain) {
        Sheet()
            .appned("new_hd_wallet".loc, do: { [weak self] _ in self?.mParent?.onNewHDWallet(chain: chain) })
            .appned("import_seed_phrase".loc, do: { [weak self] _ in self?.askSeed(chain: chain) })
            .appned("import_private_key".loc, do: { [weak self] _ in self?.askKey(chain: chain) })
            .show()
    }
    
    private func askSeed(chain: Blockchain) {
        Alert(withFieldAndName: "phrase_text".loc)
            .put(negative: "cancel".loc)
            .put("import".loc, do: { [weak self] a in
                let name = a.value
                if name.count > 0, (name.split(separator: " ").count == 12 || name.split(separator: " ").count == 24) {
                    self?.onNew(chain: chain, name: "", seed: name)
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(400), execute: {
                        Alert("incorrect_seed".loc).show()
                    })
                }
            }).show()
    }
    
    private func askKey(chain: Blockchain) {
        Alert(withFieldAndName: "key_text".loc)
            .put(negative: "cancel".loc)
            .put("import".loc, do: { [weak self] a in
                let name = a.value
                if name.count > 0 {
                    self?.onNew(chain: chain, name: "", privateKey: name)
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(400), execute: {
                        Alert("incorrect_key".loc).show()
                    })
                }
            }).show()
    }
        
    func onNew(chain: Blockchain, name: String, seed: String) {
        guard let s = try? Mnemonic.createSeed(mnemonic: seed.split(separator: " ").map({ String($0) })) else { return }
        mParent?.onNew(chain: chain, name: name, data: "01\(s.toHexString())", segwit: false)
    }
    
    func onNew(chain: Blockchain, name: String, privateKey: String) {
        mParent?.onNew(chain: chain, name: name, data: "00\(privateKey.withoutPrefix)", segwit: false)
    }

}
