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

class AlertVC : PopupVC {
    
    private let mArrow = UIImageView(image: UIImage(named: "arrowDown"))
    private let mName  = UILabel.new(font: .medium(17), lines: 0, color: Style.Colors.black, alignment: .center)
    
    private let mView: (UIView & IAlertView)?
    
    private var mButtons = [Button]()
    
    init(_ name: String? = nil, view: (UIView & IAlertView)? = nil, style: PresentationStyle = .sheet, arrow: Bool = false) {
        mView = view
        super.init(nibName: nil, bundle: nil)
        self.style = style
        if let n = name?.trimmingCharacters(in: .whitespacesAndNewlines), n.count > 0 {
            mName.isVisible = true
            mName.text = n
        } else {
            mName.isVisible = false
            mName.text = nil
        }
        mArrow.isVisible = arrow
    }

    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    @discardableResult
    func put(_ name: String, color: UIColor = Style.Colors.blue, do block: ((AlertVC)->Void)? = nil) -> Self {
        let tmp = Button()
        tmp.backgroundColor = color
        tmp.setTitle(name, for: .normal)
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
    func put(negative name: String, do block: ((AlertVC)->Void)? = nil) -> Self {
        return put(name, color: Style.Colors.green, do: block)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        content.addSubview(mName)
        if let v = mView {
            content.addSubview(v)
        }
        if mArrow.isVisible {
            content.addSubview(mArrow)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }

    override func doLayout() -> CGFloat {
        let p: CGFloat = 20.scaled
        var y: CGFloat = p
        let w: CGFloat = width
        
        if mArrow.isVisible {
            mArrow.origin = CGPoint(x: (width - mArrow.width)/2.0, y: 40.scaled)
            y = mArrow.maxY + 40.scaled
        }
        
        if mName.isVisible {
            let txtHeight = ceil((mName.text?.heightFor(width: w - p * 2, font: mName.font) ?? 0.0))
            mName.frame = CGRect(x: p, y: y, width: w - p * 2, height: txtHeight)
            y = mName.maxY + p
        }
        
        if let v = mView {
            v.layout(width: w - p*2.0, origin: CGPoint(x: p, y: y))
            y = v.maxY + p
        }
        
        if mButtons.count < 3 {
            if mButtons.count == 0 {
                put("ok".loc)
            }
            
            let w = (w - p * CGFloat(mButtons.count+1)) / CGFloat(mButtons.count)
            var x = CGFloat(0)
            mButtons.forEach({
                $0.frame = CGRect(x: x + p, y: y, width: w, height: Style.Dims.buttonMiddle)
                $0.layer.cornerRadius = $0.height/2.0
                x = $0.maxX
            })
            y = (mButtons.last?.maxY ?? y) + p
        } else {
            mButtons.forEach({
                $0.frame = CGRect(x: p, y: y, width: w-40.scaled, height: Style.Dims.buttonMiddle)
                $0.layer.cornerRadius = $0.height/2.0
                y = $0.maxY + p/2.0
            })
            y += p/2.0
        }
        
        return y
    }

}
