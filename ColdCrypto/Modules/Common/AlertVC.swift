//
//  Alert.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 20/10/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import UIKit

protocol IAlertView: class {
    func layout(width: CGFloat, origin: CGPoint)
}

extension UIImageView: IAlertView {
    func layout(width: CGFloat, origin o: CGPoint) {
        if self.width > 0 && self.height > 0 {
            let w = self.width > width ? width : self.width
            let h = w * self.height / self.width
            frame = CGRect(x: o.x + (width - w)/2.0, y: o.y, width: w, height: h)
        }
    }
}

class AlertVC : PopupVC {
    
    private let mArrow = UIImageView(image: UIImage(named: "arrowDown"))
    private let mName  = UILabel.new(font: .medium(17), lines: 0, color: Style.Colors.black, alignment: .center)
    
    private var mView: (UIView & IAlertView)?
    
    private var mButtons = [Button]()
    
    private var mWithButtons: Bool
    var withButtons: Bool {
        get {
            return mWithButtons
        }
        set {
            mWithButtons = newValue
        }
    }
    
    private var mWithArrow = true
    var withArrow: Bool {
        set {
            mWithArrow = newValue
            mArrow.alpha = newValue ? 1.0 : 0.0
        }
        get {
            return mWithArrow
        }
    }
    
    private var mContent = UIView()
    
    private var mDragable = true
    override var dragable: Bool {
        return mDragable
    }
    
    init(_ name: String? = nil,
         view: (UIView & IAlertView)? = nil,
         style: PresentationStyle = .sheet,
         arrow: Bool = false,
         withButtons: Bool = true,
         draggable: Bool = true) {
        mView = view
        mDragable = draggable
        mWithButtons = withButtons
        super.init(nibName: nil, bundle: nil)
        self.style = style
        if let n = name?.trimmingCharacters(in: .whitespacesAndNewlines), n.count > 0 {
            mName.isVisible = true
            mName.text = n
        } else {
            mName.isVisible = false
            mName.text = nil
        }
        withArrow = arrow
    }

    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    func clearButtons() {
        mButtons.forEach({
            $0.removeFromSuperview()
        })
        mButtons.removeAll()
    }
    
    @discardableResult
    func put(_ name: String, color: UIColor = Style.Colors.blue, hide: Bool = true, do block: ((AlertVC)->Void)? = nil) -> Self {
        withButtons = true
        let tmp = Button()
        tmp.backgroundColor = color
        tmp.setTitle(name, for: .normal)
        mContent.addSubview(tmp)
        mButtons.append(tmp)
        tmp.click = { [weak self] in
            if let s = self {
                block?(s)
                if hide {
                    s.hide()
                }
            }
        }
        return self
    }
    
    @discardableResult
    func put(negative name: String, do block: ((AlertVC)->Void)? = nil) -> Self {
        return put(name, color: Style.Colors.green, do: block)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        content.addSubview(mName)
        content.addSubview(mContent)
        content.addSubview(mArrow)
        if let v = mView {
            mContent.addSubview(v)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }

    @discardableResult
    override func doLayout() -> CGFloat {
        let p: CGFloat = style == .sheet ? Style.Dims.middle : Style.Dims.small
        var y: CGFloat = p
        let w: CGFloat = width
        
        mArrow.origin = CGPoint(x: (width - mArrow.width)/2.0, y: 40.scaled)
        if mArrow.alpha > 0.5 {
            y = mArrow.maxY + 40.scaled
        }
        
        mContent.frame = CGRect(x: 0, y: y, width: width, height: mContent.height)
        y = 0
        
        if mName.isVisible {
            let txtHeight = ceil((mName.text?.heightFor(width: w - p * 2, font: mName.font) ?? 0.0))
            mName.frame = CGRect(x: p, y: y+p, width: w - p * 2, height: txtHeight)
            y = mName.maxY + p
        }
        
        if let v = mView {
            v.layout(width: w - p*2.0, origin: CGPoint(x: p, y: y))
            y = v.maxY + p
        }
        
        if mWithButtons && mButtons.count < 3 {
            if mButtons.count == 0 {
                put("ok".loc)
            }
            
            let w = (w - p * CGFloat(mButtons.count+1)) / CGFloat(mButtons.count)
            var x = CGFloat(0)
            mButtons.forEach({
                $0.frame = CGRect(x: x + p, y: y, width: w, height: Style.Dims.middle)
                $0.setNeedsLayout()
                $0.layoutIfNeeded()
                $0.layer.cornerRadius = $0.height/2.0
                x = $0.maxX
            })
            y = (mButtons.last?.maxY ?? y) + p
        } else if mWithButtons {
            mButtons.forEach({
                $0.frame = CGRect(x: p, y: y, width: w-40.scaled, height: Style.Dims.middle)
                $0.setNeedsLayout()
                $0.layoutIfNeeded()
                $0.layer.cornerRadius = $0.height/2.0
                y = $0.maxY + p/2.0
            })
            y += p/2.0
        }
        
        mContent.frame.size.height = y
        return mContent.maxY
    }
    
    func update(view newView: UIView & IAlertView, configure: @escaping ()->Void, animate: (()->Void)? = nil) {
        UIView.animate(withDuration: 0.25, animations: {
            self.mContent.alpha = 0.0
        }, completion: { _ in
            self.mView?.removeFromSuperview()
            self.mView = newView
            self.mContent.addSubview(newView)
            configure()
            self.doLayout()
            UIView.animate(withDuration: 0.25, animations: {
                animate?()
                self.view.setNeedsLayout()
                self.view.layoutIfNeeded()
                self.mContent.alpha = 1.0
            })
        })
    }
    
}
