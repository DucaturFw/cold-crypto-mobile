//
//  HistoryCell.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 05/12/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import UIKit

protocol HistoryCellDelegate: class {
    func onSelected(cell: HistoryCell)
}

class HistoryCell: UITableViewCell {

    static let defHeight = 68.scaled
    
    weak var delegate: HistoryCellDelegate?
    
    var isLast: Bool = false {
        didSet {
            mLine.isHidden = isLast
        }
    }
    
    var transaction: ITransaction? {
        didSet {
            mName.text  = transaction?.name  ?? ""
            mValue.text = transaction?.value ?? ""
            mText.text  = transaction?.text  ?? ""
            
            let p = transaction?.positive == true
            mValue.textColor = (p ? Style.Colors.blue : Style.Colors.red).darker()
            mValue.sizeToFit()
            mText.sizeToFit()
            
            setNeedsLayout()
        }
    }
    
    private let mName  = UILabel.new(font: .medium(15.scaled), lines: 1, color: 0x32325D.color, alignment: .left)
    private let mValue = UILabel.new(font: .bold(14.scaled), lines: 1, color: 0x32325D.color, alignment: .left)
    private let mText  = UILabel.new(font: .bold(14.scaled), lines: 1, color: 0xC7CCD7.color, alignment: .left)
    
    private let mLine  = UIView().apply({
        $0.backgroundColor = Style.Colors.darkLight
    })
    
    var bottomView: UIView? {
        didSet {
            oldValue?.removeFromSuperview()
            if let v = bottomView {
                addSubview(v)
                layout()
            }
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        clipsToBounds   = true
        backgroundColor = .clear
        backgroundView  = UIView()
        selectionStyle  = .none

        addSubview(mLine)
        addSubview(mName)
        addSubview(mText)
        addSubview(mValue)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapped))
        tap.delegate = self
        addGestureRecognizer(tap)
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layout()
    }
    
    @objc private func tapped() {
        delegate?.onSelected(cell: self)
    }
    
    @objc private func layout() {
        let p = 40.scaled
        mLine.frame   = CGRect(x: p, y: height - 1, width: width-80.scaled, height: 1)
        mName.frame   = CGRect(x: p, y: 20.scaled, width: width - p*2.0, height: mName.font.lineHeight)
        mText.origin  = CGPoint(x: p, y: 40.scaled)
        mValue.origin = CGPoint(x: width - p - mValue.width, y: mText.minY)
        if let v = bottomView {
            v.frame = CGRect(x: 0, y: HistoryCell.defHeight, width: width, height: v.height)
        }
    }
            
}
