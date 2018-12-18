//
//  ETHForm.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 02/12/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import UIKit

class ETHForm: UIView, UITextFieldDelegate, IWithValue {
    
    private let mCaption = UILabel.new(font: UIFont.medium(25.scaled), text: "enter_seed_pk".loc, lines: 0, color: Style.Colors.black, alignment: .center)

    private lazy var mField  = UITextField().apply({ [weak self] in
        $0.returnKeyType = .done
        $0.autocorrectionType = .no
        $0.autocapitalizationType = .none
        $0.backgroundColor = Style.Colors.light
        $0.layer.cornerRadius = Style.Dims.middle/2.0
        $0.layer.borderWidth = 0.0
        $0.delegate = self
        $0.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        $0.leftViewMode = .always
        $0.font = UIFont.medium(13)
        $0.textColor = Style.Colors.black
        $0.addTarget(self, action: #selector(changed), for: .editingChanged)
    })
    private let mDerive = Button().apply({
        $0.setTitle("derive".loc, for: .normal)
        $0.backgroundColor = Style.Colors.blue
    })
    
    var onValid: (Bool)->Void = { _ in }
    var onDerive: ()->Void = {}
    var onScan: ()->Void = {}
    
    private(set) var isValid: Bool = false {
        didSet {
            onValid(isValid)
        }
    }
    
    var value: String {
        get {
            return (mField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        }
        set {
            mField.text = newValue
            changed()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(mCaption)
        addSubview(mField)
        addSubview(mDerive)
        mDerive.click = { [weak self] in
            self?.onDerive()
        }
        mField.rightView = UIImageView(image: UIImage(named: "scanIcon")).apply({
            $0.contentMode = .center
            $0.transform = CGAffineTransform(rotationAngle: CGFloat.pi/2.0)
            $0.frame = $0.frame.insetBy(dx: -15, dy: -15)
        }).tap({ [weak self] in
            self?.onScan()
        })
        mField.rightViewMode = .always
        mField.attributedPlaceholder = NSAttributedString(string: "your_pk".loc,
                                                                attributes: [.font: UIFont.medium(13), .foregroundColor: Style.Colors.darkLight])
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        mCaption.origin = CGPoint(x: (width - mCaption.width)/2.0, y: 0)
        mField.frame    = CGRect(x: 0, y: mCaption.maxY + 30.scaled, width: width, height: Style.Dims.middle)
        mDerive.frame   = CGRect(x: 0, y: mField.maxY + Style.Dims.small, width: width, height: Style.Dims.middle)
        frame.size.height = mDerive.maxY
    }
    
    @objc private func changed() {
        isValid = (mField.text?.count ?? 0) > 0
    }
    
    func shakeField() {
        mField.shake()
    }
    
    // MARK: - UITextFieldDelegate methods
    // -------------------------------------------------------------------------
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return false
    }
    
}
