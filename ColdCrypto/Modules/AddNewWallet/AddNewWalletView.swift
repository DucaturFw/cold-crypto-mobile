//
//  AddNewWalletView.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 17/12/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import UIKit

protocol AddWalletDelegate: class {
    func onSelected(blockchain: Blockchain)
    func onCancel(sender: AddNewWalletView)
}

class AddNewWalletView: UIView, IAlertView {

    private var mBlockchain: Blockchain?
    
    private let mPicker  = CryptoList()
    private let mBlock   = UILabel.new(font: UIFont.medium(25.scaled), text: "select_chain".loc, lines: 1, color: Style.Colors.black, alignment: .center)

    private let mCancel = Button().apply({
        $0.setTitle("cancel".loc, for: .normal)
        $0.backgroundColor = Style.Colors.darkGrey
    })
    
    private let mImport = Button().apply({
        $0.setTitle("import".loc, for: .normal)
        $0.backgroundColor = Style.Colors.blue
        $0.isActive = false
    })
    
    var isActive: Bool = false {
        didSet {
            mImport.isActive = isActive
        }
    }
    
    weak var delegate: AddWalletDelegate?
    
    private var mViews: [UIView] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(mPicker)
        addSubview(mBlock)
        addSubview(mImport)
        addSubview(mCancel)
        
        mPicker.onSelect = { [weak self] b in
            self?.selected(blockchain: b)
        }
        mCancel.click = { [weak self] in
            if let s = self {
                s.delegate?.onCancel(sender: s)
            }
        }
        mImport.click = { [weak self] in
            self?.doImport()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    func collapseBlockchain() {
        mPicker.collapse()
    }
    
    private func doImport() {
        //        guard let b = mBlockchain else { return }
        //        switch b {
        //        case .ETH:
        //            let name = mETHForm.value
        //            if name.count > 0, (name.split(separator: " ").count == 12 || name.split(separator: " ").count == 24) {
        //                onNew(chain: b, name: "", seed: name)
        //            } else if name.count > 0, name.range(of: " ") == nil {
        //                onNew(chain: b, name: "", privateKey: name)
        //            } else {
        //                mETHForm.shakeField()
        //            }
        //        case .EOS:
        //            if
        //                let p = mEOSForm.privateKey,
        //                let a = mEOSForm.selected,
        //                let w = EOSWallet(name: a, data: "00\(p)", privateKey: p, time: Date().timeIntervalSince1970) {
        //                AppDelegate.lock()
        //                dismiss(animated: true, completion: {
        //                    self.mDelegate?.onNew(wallet: w)
        //                    AppDelegate.unlock()
        //                })
        //            } else {
        //                mEOSForm.shakeField()
        //            }
        //        }
    }
    
    private func selected(blockchain: Blockchain) {
        mBlockchain = blockchain
        delegate?.onSelected(blockchain: blockchain)
    }
    
    func layout(width: CGFloat, origin o: CGPoint) {
        mBlock.alpha  = mBlockchain == nil ? 1.0 : 0.0
        mBlock.origin = CGPoint(x: (width - mBlock.width)/2.0, y: 0)
        mPicker.frame = CGRect(x: 0, y: mBlockchain == nil ? (mBlock.maxY + 30.scaled) : 0, width: width, height: 0)
        mPicker.setNeedsLayout()
        mPicker.layoutIfNeeded()
        
        var y = mPicker.maxY + 30.scaled
        mViews.forEach({
            $0.frame = CGRect(x: 0, y: y, width: width, height: $0.height)
            $0.setNeedsLayout()
            $0.layoutIfNeeded()
            y = $0.maxY + 30.scaled
        })
        let p = 40.scaled
        let w = (width - p)/2.0
        
        mCancel.frame = CGRect(x: 0, y: y, width: w, height: Style.Dims.middle)
        mImport.frame = CGRect(x: mCancel.maxX + p, y: mCancel.minY, width: w, height: mCancel.height)

        frame = CGRect(origin: o, size: CGSize(width: width, height: mCancel.maxY))
    }
    
    func append(view: UIView) {
        let top = mViews.last?.maxY ?? mPicker.maxY
        mViews.append(view)
        addSubview(view)
        UIView.performWithoutAnimation {
            view.frame = CGRect(x: 0, y: top, width: width, height: view.height)
            view.setNeedsLayout()
            view.layoutIfNeeded()
        }
    }
    
}
