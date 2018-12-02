//
//  Alert.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 20/10/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import UIKit

class Alert : PopupVC {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    class EmptyVC: UIViewController {
        
        private weak var mParent: Alert?
        
        override var preferredStatusBarStyle: UIStatusBarStyle {
            return mParent?.preferredStatusBarStyle ?? .lightContent
        }
        
        init(alert: Alert) {
            super.init(nibName: nil, bundle: nil)
            mParent = alert
        }
        
        required init?(coder aDecoder: NSCoder) {
            return nil
        }
        
    }
    
    enum State {
        case hidden, shown
    }
    
    var boxWidth: CGFloat {
        return 270.0
    }
    
    var value: String {
        return mView?.value ?? ""
    }
    
    private var alertWindow: UIWindow?
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        alertWindow?.removeFromSuperview()
        alertWindow?.isHidden = true
        alertWindow = nil
    }
    
    private lazy var mName = UILabel.new(font: .proMedium(17), lines: 0, color: Style.Colors.black, alignment: .center)
    
    private let mView: (UIView & IAlertView)?
    
    private var mButtons = [Button]()
    
    init(_ name: String? = nil, view: (UIView & IAlertView)? = nil) {
        mView = view
        super.init(nibName: nil, bundle: nil)
        if let n = name?.trimmingCharacters(in: .whitespacesAndNewlines), n.count > 0 {
            mName.isVisible = true
            mName.text = n
        } else {
            mName.isVisible = false
            mName.text = nil
        }
    }

    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    @discardableResult
    func put(_ name: String, color: UIColor = Style.Colors.blue, do block: ((Alert)->Void)? = nil) -> Self {
        let tmp = Button()
        tmp.backgroundColor = color
        tmp.setTitle(name, for: .normal)
        tmp.layer.cornerRadius = Style.Dims.buttonLarge/2.0
        content.addSubview(tmp)
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
        return put(name, color: Style.Colors.green, do: block)
    }
    
    func show() {
        guard let w = UIApplication.shared.windows.first else { return }
        show(in: w)
    }
    
    func show(in window: UIView) {
        if alertWindow != nil { return }
        alertWindow = UIWindow(frame: UIScreen.main.bounds)
        alertWindow?.layer.cornerRadius  = 10.scaled
        alertWindow?.layer.masksToBounds = true
        alertWindow?.rootViewController  = EmptyVC(alert: self)
        alertWindow?.windowLevel = UIWindow.Level(rawValue: (UIApplication.shared.windows.last?.windowLevel.rawValue ?? 0.0) + 1.0)
        alertWindow?.makeKeyAndVisible()
        alertWindow?.rootViewController?.present(self, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        content.addSubview(mName)
        if let v = mView {
            content.addSubview(v)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }

    override func doLayout() -> CGFloat {
        let p: CGFloat = 20.scaled
        var y: CGFloat = p
        let w: CGFloat = view.width
        
        if mName.isVisible {
            let txtHeight = ceil((mName.text?.heightFor(width: w - p * 2, font: mName.font) ?? 0.0))
            mName.frame = CGRect(x: p, y: y, width: w - p * 2, height: txtHeight)
            y = mName.maxY + p
        }
        
        if let v = mView {
            let s = v.sizeFor(width: w - p*2.0)
            v.frame = CGRect(x: p, y: y, width: s.width, height: s.height)
            y = v.maxY + p
        }
        
        if mButtons.count < 3 {
            if mButtons.count == 0 {
                put("ok".loc)
            }
            
            let w = (w - p * CGFloat(mButtons.count+1)) / CGFloat(mButtons.count)
            var x = CGFloat(0)
            mButtons.forEach({
                $0.frame = CGRect(x: x + p, y: y, width: w, height: Style.Dims.buttonLarge)
                x = $0.maxX
            })
            y = (mButtons.last?.maxY ?? y) + p
        } else {
            mButtons.forEach({
                $0.frame = CGRect(x: p, y: y, width: w-40.scaled, height: Style.Dims.buttonLarge)
                y = $0.maxY + p/2.0
            })
            y += p/2.0
        }
        
        return y
    }

    @objc func hide() {
        dismiss(animated: true, completion: nil)
    }

}
