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
    func onCancel(sender: NewWalletView)
}

class NewWalletView: UIView, IAlertView {

    private var mBlockchain: Blockchain?
    
    private let mPicker  = ChainPicker()
    private let mBlock   = UILabel.new(font: UIFont.medium(25.scaled), text: "select_chain".loc, lines: 1, color: Style.Colors.black, alignment: .center)
    
    weak var delegate: AddWalletDelegate?
    
    private var mViews: [UIView] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(mPicker)
        addSubview(mBlock)
        mPicker.onSelect = { [weak self] b in
            self?.selected(blockchain: b)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    func collapseBlockchain() {
        mPicker.collapse()
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
        frame = CGRect(origin: o, size: CGSize(width: width, height: y))
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
