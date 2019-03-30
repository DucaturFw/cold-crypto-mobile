//
//  TokenList.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 03/03/2019.
//  Copyright © 2019 Kirill Kozhuhar. All rights reserved.
//

import UIKit

class TokenList: UIView, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {

    private let mFlow: UICollectionViewFlowLayout = {
        let tmp = UICollectionViewFlowLayout()
        tmp.scrollDirection = .horizontal
        tmp.minimumInteritemSpacing = 10
        tmp.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        tmp.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        tmp.itemSize = UICollectionViewFlowLayout.automaticSize
        return tmp
    }()
    
    private var mTokens: [TokenObj] = []
    
    private let mLeft  = Gradient()
    private let mRight = Gradient().apply({
        $0.transform = CGAffineTransform(scaleX: -1, y: 1)
    })
    
    private lazy var mList = UICollectionView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 80), collectionViewLayout: self.mFlow).apply({
        $0.backgroundColor = .clear
        $0.backgroundView  = UIView()
        $0.showsHorizontalScrollIndicator = false
    })
    
    var tint: UIImage? = nil {
        didSet {
            reload()
        }
    }
    
    var onToken: (TokenObj)->Void = { _ in }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(mList)
        addSubview(mLeft)
        addSubview(mRight)
        mList.delegate = self
        mList.dataSource = self
        TokenCell.registerNib(in: mList)
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let p = 26.scaled
        mList.frame = CGRect(x: p, y: 0, width: width - p*2.0, height: height)
        mLeft.frame = CGRect(x: p, y: 0, width: 10, height: height)
        mRight.frame = CGRect(x: width - 10 - p, y: 0, width: 10, height: height)
        reload()
    }
    
    private func show(token: TokenObj) {
        
    }
    
    func update(tokens: [TokenObj]) {
        mTokens = tokens
        reload()
    }
    
    func reload() {
        mList.setNeedsLayout()
        mList.reloadData()
        mList.collectionViewLayout.invalidateLayout()
        mList.updateConstraintsIfNeeded()
    }
    
    // MARK: - UICollectionViewDelegate, UICollectionViewDataSource methods
    // -------------------------------------------------------------------------
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let token = mTokens[indexPath.item]
        return TokenCell.get(from: mList, at: indexPath).apply({
            $0.value = token.amount.compactValue
            $0.units = token.name
            $0.tint  = tint
            $0.onTapped = { [weak self] in
                self?.onToken(token)
            }
            $0.updateConstraintsIfNeeded()
        })
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mTokens.count
    }
    
}
