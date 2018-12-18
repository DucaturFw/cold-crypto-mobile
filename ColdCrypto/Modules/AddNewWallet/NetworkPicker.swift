//
//  NetworkPicker.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 18/12/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import UIKit

class NetworkPicker: UIView {
    
    var onSelected: (INetwork)->Void = { _ in}
    
    private var mSelected: UIView?
    
    private let mScroll = UIScrollView().apply({
        $0.showsHorizontalScrollIndicator = false
        $0.showsVerticalScrollIndicator = false
    })
    
    private var mViews = [UIView]()
    var networks: [INetwork] = [] {
        didSet {
            mViews.forEach({ $0.removeFromSuperview() })
            var x = CGFloat(0)
            networks.forEach({ n in
                let v = UILabel.new(font: .medium(15.scaled),
                                    lines: 1,
                                    color: .white,
                                    alignment: .center)
                v.frame = CGRect(x: x, y: 0, width: 120.scaled, height: height)
                v.layer.cornerRadius = v.height/2.0
                x = v.maxX + 10.scaled
                v.backgroundColor = 0x736C82.color
                v.layer.masksToBounds = true
                v.text = n.name
                mScroll.addSubview(v)
                mViews.append(v)
                v.tap({ [weak self, weak v] in
                    if let v = v {
                        self?.selected(network: n, view: v)
                    }
                })
            })
            adjustInsets()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(mScroll)
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        frame.size.height = Style.Dims.middle
        mScroll.frame = bounds
        var x = CGFloat(0)
        mViews.forEach({
            let g = CGRect(x: x, y: 0, width: 120.scaled, height: height)
            if $0 == mSelected {
                $0.frame = CGRect(x: (width - 120.scaled)/2.0, y: 0, width: 120.scaled, height: height)
                $0.alpha = 1.0
            } else {
                $0.frame = g
                $0.alpha = mSelected != nil ? 0.0 : 1.0
            }
            $0.layer.cornerRadius = $0.height/2.0
            x = g.maxX + 10.scaled
        })
        mScroll.contentSize.width = max(x - 10.scaled, 0)
        adjustInsets()
    }
    
    private func adjustInsets() {
        mScroll.contentInset.left = max((mScroll.width - mScroll.contentSize.width)/2.0, 0)
    }
    
    private func selected(network: INetwork, view: UIView) {
        view.backgroundColor = Style.Colors.blue
        isUserInteractionEnabled = false
        mSelected = view
        view.frame = view.convert(view.bounds, to: self)
        addSubview(view)
        onSelected(network)
    }
    
//    // MARK:- UICollectionViewDelegate, UICollectionViewDataSource methods
//    // -------------------------------------------------------------------------
//    func collectionView(_ collectionView: UICollectionView,
//                        numberOfItemsInSection section: Int) -> Int {
//        return networks.count
//    }
//
//    func collectionView(_ collectionView: UICollectionView,
//                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = NetworkCell.get(from: collectionView, at: indexPath)
//        cell.network = networks[indexPath.row]
//        return cell
//    }
//
//    func collectionView(_ collectionView: UICollectionView,
//                        layout collectionViewLayout: UICollectionViewLayout,
//                        sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: 120.scaled, height: height)
//    }
//
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let n = networks[indexPath.item]
//        networks = [n]
//    }
    
}
