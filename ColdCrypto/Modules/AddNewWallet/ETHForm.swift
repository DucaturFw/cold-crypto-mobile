//
//  ETHForm.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 02/12/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import UIKit

class ETHForm: UIView, ImportFieldDelegate, IWithValue {
    
    private let mCaption = UILabel.new(font: UIFont.medium(25.scaled), text: "enter_seed_pk".loc, lines: 0, color: Style.Colors.black, alignment: .center)

    private lazy var mField = ImportField(delegate: self)
    
    private let mDerive = Button().apply({
        $0.setTitle("derive".loc, for: .normal)
        $0.backgroundColor = Style.Colors.darkGrey
    })
    
    private let mImport = Button().apply({
        $0.setTitle("import".loc, for: .normal)
        $0.backgroundColor = Style.Colors.blue
        $0.isActive = false
    })
    
    var onDerive: ()->Void = {}
    var onImport: ()->Void = {}
    var onScan: ()->Void = {}
    
    var value: String {
        get {
            return mField.value
        }
        set {
            mField.value = newValue
        }
    }
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(mCaption)
        addSubview(mField)
        addSubview(mDerive)
        addSubview(mImport)
        mDerive.click = { [weak self] in
            self?.onDerive()
        }
        mImport.click = { [weak self] in
            self?.onImport()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        mCaption.origin = CGPoint(x: (width - mCaption.width)/2.0, y: 0)
        mField.frame    = CGRect(x: 0, y: mCaption.maxY + 30.scaled, width: width, height: Style.Dims.middle)
        mImport.frame   = CGRect(x: 0, y: mField.maxY + Style.Dims.small, width: width, height: Style.Dims.middle)
        mDerive.frame   = CGRect(x: 0, y: mImport.maxY + Style.Dims.small, width: width, height: Style.Dims.middle)
        frame.size.height = mDerive.maxY
    }
    
    func shakeField() {
        mField.shake()
    }
    
    // MARK: - ImportFieldDelegate methods
    // -------------------------------------------------------------------------
    func onScan(from: ImportField) {
        onScan()
    }
    
    func onChanged(from: ImportField) {
        let parts = from.value.split(separator: " ")
        if parts.count <= 1 {
            mImport.isActive = from.value.count > 0 && Data(hex: from.value).count > 0
        } else if parts.count == 12 || parts.count == 24 {
            mImport.isActive = ETHWallet.makeSeed(from: from.value) != nil
        } else {
            mImport.isActive = false
        }
    }
    
    func onReturn(from: ImportField) -> Bool {
        from.endEditing(true)
        return false
    }
    
    func onSearch(from: ImportField) {}

}
