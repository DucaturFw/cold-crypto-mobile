//
//  Alert.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 20/10/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import UIKit

class Alert : UIView {
    
    enum State {
        case hidden, shown
    }
    
    var boxWidth: CGFloat {
        return 270.0
    }

    private var state: State = .hidden {
        didSet {
            updateState()
        }
    }
    
    var value: String {
        return mView?.value ?? ""
    }
    
    private var mIsInAnimation: Bool = true
    
    private let mBlur = UIVisualEffectView()
    
    private lazy var mName = UILabel.new(font: .sfProSemibold(17), lines: 0, color: 0x32325D.color, alignment: .center)
    
    private var mOverlay: UIView = {
        let tmp = UIView(frame: UIScreen.main.bounds)
        tmp.backgroundColor = UIColor.black.withAlphaComponent(0.05)
        tmp.alpha = 0.0
        return tmp
    }()
    
    private lazy var mBox: UIView = { [weak self] in
        let tmp = UIView(frame: CGRect(x: 0, y: 0, width: self?.boxWidth ?? 300, height: 0))
        tmp.backgroundColor = .white
        tmp.layer.cornerRadius = 6
        tmp.layer.shadowColor = 0x44519E.color.cgColor
        tmp.layer.shadowOffset = CGSize(width: 0, height: 10)
        tmp.layer.shadowRadius = 10
        tmp.layer.shadowOpacity = 0.3
        tmp.clipsToBounds = true
        return tmp
    }()
    
    private let mView: (UIView & IAlertView)?
    
    private var mButtons = [Button]()
    
//    private let mPositive: Button = {
//        let tmp = Button()
//        tmp.isVisible = false
//        tmp.backgroundColor = 0x1888FE.color
//        tmp.layer.cornerRadius = 0
//        return tmp
//    }()

//    private let mNegative: Button = {
//        let tmp = Button()
//        tmp.isVisible = false
//        tmp.backgroundColor = 0x26E7B0.color
//        tmp.layer.cornerRadius = 0
//        return tmp
//    }()

    convenience init(withFieldAndName name: String) {
        self.init(name, view: AlertField())
    }
    
    init(_ name: String? = nil, view: (UIView & IAlertView)? = nil) {
        mView = view
        super.init(frame: UIScreen.main.bounds)
        mBlur.isUserInteractionEnabled = false
        mBlur.effect = nil
        addSubview(mBlur)
        addSubview(mOverlay)
        addSubview(mBox)
        mBox.addSubview(mName)
                
        if let n = name?.trimmingCharacters(in: .whitespacesAndNewlines), n.count > 0 {
            mName.isVisible = true
            mName.text = n
        } else {
            mName.isVisible = false
            mName.text = nil
        }
        
        if let v = mView {
            mBox.addSubview(v)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    @discardableResult
    func put(_ name: String, color: UIColor = 0x1888FE.color, do block: ((Alert)->Void)? = nil) -> Self {
        let tmp = Button()
        tmp.backgroundColor = color
        tmp.setTitle(name, for: .normal)
        tmp.layer.cornerRadius = 0
        mBox.addSubview(tmp)
        mButtons.append(tmp)
        tmp.click = { [weak self] in
            if let s = self {
                block?(s)
                s.hide()
            }
        }
        return self
    }
    
    @discardableResult
    func put(negative name: String, do block: ((Alert)->Void)? = nil) -> Self {
        return put(name, color: 0x26E7B0.color, do: block)
    }
    
    func show() {
        guard let w = UIApplication.shared.windows.first else { return }
        show(in: w)
    }
    
    func show(in window: UIView) {
        frame = window.bounds
        window.addSubview(self)
        mBlur.effect = nil
        
        forceLayout()
        updateState()
        
        mIsInAnimation = true
        UIView.animate(withDuration: 0.6, delay: 0.2, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: [], animations: {
            self.mBlur.effect = UIBlurEffect(style: .regular)
            self.state = .shown
        }, completion: { _ in
            self.mIsInAnimation = false
            self.mView?.focusAtStart()
        })
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if (mIsInAnimation) { return }
        forceLayout()
    }
    
    private func forceLayout() {
        mBlur.frame = bounds
        mOverlay.frame = bounds
        
        let padding = CGFloat(20)
        var y: CGFloat = padding

        if mName.isVisible {
            let txtHeight = ceil((mName.text?.heightFor(width: mBox.width - padding * 2, font: mName.font) ?? 0.0))
            mName.frame = CGRect(x: padding, y: y, width: mBox.width - padding * 2, height: txtHeight)
            y = mName.maxY + 20
        }

        if let v = mView {
            let s = v.sizeFor(width: mBox.width - padding*2.0)
            v.frame = CGRect(x: padding, y: y, width: s.width, height: s.height)
            y = v.maxY + 20
        }
        
        if mButtons.count < 3 {
            if mButtons.count == 0 {
                put("ok".loc)
            }
            
            let w = mBox.width / CGFloat(mButtons.count)
            var x = CGFloat(0)
            mButtons.forEach({
                $0.frame = CGRect(x: x, y: y, width: w, height: CGFloat(45))
                x = $0.maxX
            })
            y = mButtons.last?.maxY ?? y
        } else {
            mButtons.forEach({
                $0.frame = CGRect(x: 0, y: y, width: mBox.width, height: CGFloat(45))
                y = $0.maxY
            })
        }

        mBox.frame = CGRect(x: (width - mBox.width)/2.0, y: (height - y)/2.0, width: mBox.width, height: y)
    }
    
    func updateState() {
        mBox.transform = CGAffineTransform(translationX: 0, y: state == .shown ? 0 : height)
        mOverlay.alpha = state == .shown ? 1.0 : 0.0
    }
    
    @objc func hide() {
        mIsInAnimation = true
        UIView.animate(withDuration: 0.4, animations: {
            self.mBlur.effect = nil
            self.state = .hidden
        }) { (_) in
            self.mIsInAnimation = false
            self.removeFromSuperview()
        }
    }
        
}
