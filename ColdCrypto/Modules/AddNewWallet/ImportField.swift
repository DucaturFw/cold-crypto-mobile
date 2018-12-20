//
//  ImportField.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 20/12/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import UIKit

protocol ImportFieldDelegate: class {
    func onScan(from: ImportField)
    func onSearch(from: ImportField)
    func onChanged(from: ImportField)
    func onReturn(from: ImportField) -> Bool
}

class ImportField: UIView, UITextFieldDelegate {
    
    private lazy var mField = UITextField().apply({ [weak self] in
        $0.returnKeyType = .done
        $0.autocorrectionType = .no
        $0.autocapitalizationType = .none
        $0.backgroundColor = Style.Colors.light
        $0.layer.cornerRadius = Style.Dims.middle/2.0
        $0.layer.borderWidth = 1.0
        $0.layer.borderColor = Style.Colors.darkGrey.cgColor
        $0.delegate = self
        $0.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        $0.leftViewMode = .always
        $0.font = UIFont.medium(13)
        $0.textColor = Style.Colors.black
        $0.addTarget(self, action: #selector(changed), for: .editingChanged)
        $0.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        $0.rightViewMode = .always
    })
    
    private lazy var mScan = UIImageView(image: UIImage(named: "scanWhite")).apply({
        $0.backgroundColor = Style.Colors.darkGrey
        $0.contentMode = .center
        $0.frame = CGRect(x: 0, y: 0, width: 40.scaled, height: 40.scaled)
        $0.layer.cornerRadius = $0.height/2.0
        $0.clipsToBounds = true
    }).tap({ [weak self] in
        if let s = self {
            s.mDelegate?.onScan(from: s)
        }
    })
    
    var searchVisible = false {
        didSet {
            mSearch.isVisible = searchVisible
            doLayout()
        }
    }
    
    private lazy var mSearch = UIImageView(image: UIImage(named: "search")).apply({
        $0.backgroundColor = Style.Colors.darkGrey
        $0.contentMode = .center
        $0.isVisible = false
        $0.frame = CGRect(x: 0, y: 0, width: 40.scaled, height: 40.scaled)
        $0.layer.cornerRadius = $0.height/2.0
        $0.clipsToBounds = true
    }).tap({ [weak self] in
        if let s = self {
            s.mDelegate?.onSearch(from: s)
        }
    })
  
    var value: String {
        get {
            return (mField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        }
        set {
            mField.text = newValue
            changed()
        }
    }
    
    private weak var mDelegate: ImportFieldDelegate?
    
    init(delegate: ImportFieldDelegate) {
        mDelegate = delegate
        super.init(frame: .zero)
        addSubview(mField)
        addSubview(mScan)
        addSubview(mSearch)
        mField.attributedPlaceholder = NSAttributedString(string: "your_pk".loc,
                                                          attributes: [.font: UIFont.medium(13),
                                                                       .foregroundColor: Style.Colors.darkLight])
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        doLayout()
    }
    
    private func doLayout() {
        mScan.origin = CGPoint(x: (width - mScan.width), y: (height - mScan.height)/2.0)
        var x = mScan.minX - 10.scaled
        
        if mSearch.isVisible {
            mSearch.origin = CGPoint(x: x - mSearch.width - 10.scaled, y: (height - mSearch.height)/2.0)
            x = mSearch.minX - 10.scaled
        }
        
        mField.frame = CGRect(x: 0, y: 0, width: x, height: height)
    }
    
    @objc private func changed() {
        mDelegate?.onChanged(from: self)
    }
    
    // MARK: - UITextFieldDelegate methods
    // -------------------------------------------------------------------------
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return mDelegate?.onReturn(from: self) ?? false
    }
    
}
