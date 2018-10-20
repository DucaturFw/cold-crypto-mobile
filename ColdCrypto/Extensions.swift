//
//  Extensions.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 20/10/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import Foundation
import MBProgressHUD
import UIKit

extension UIFont {
    
    static func sfProMedium(_ size: CGFloat) -> UIFont {
        return UIFont(name: "SFProDisplay-Medium", size: size) ?? UIFont.boldSystemFont(ofSize: size)
    }
    
    static func sfProRegular(_ size: CGFloat) -> UIFont {
        return UIFont(name: "SFProDisplay-Regular", size: size) ?? UIFont.systemFont(ofSize: size)
    }
    
    static func sfProSemibold(_ size: CGFloat) -> UIFont {
        return UIFont(name: "SFProDisplay-Semibold", size: size) ?? UIFont.boldSystemFont(ofSize: size)
    }
    
    static func sfProBold(_ size: CGFloat) -> UIFont {
        return UIFont(name: "SFProDisplay-Bold", size: size) ?? UIFont.boldSystemFont(ofSize: size)
    }
    
}


extension UIColor {
    
    func lighter(by percentage:CGFloat=15.0) -> UIColor? {
        return self.adjust(by: abs(percentage) )
    }
    
    func darker(by percentage:CGFloat=15.0) -> UIColor? {
        return self.adjust(by: -1 * abs(percentage) )
    }
    
    func adjust(by percentage:CGFloat=30.0) -> UIColor? {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0;
        if (self.getRed(&r, green: &g, blue: &b, alpha: &a)) {
            return UIColor(red: min(r + percentage/100, 1.0),
                           green: min(g + percentage/100, 1.0),
                           blue: min(b + percentage/100, 1.0),
                           alpha: a)
        } else {
            return nil
        }
    }
    
    convenience init(r: Int, g: Int, b: Int) {
        self.init(red:   max(min(CGFloat(r), 255.0), 0.0) / 255.0,
                  green: max(min(CGFloat(g), 255.0), 0.0) / 255.0,
                  blue:  max(min(CGFloat(b), 255.0), 0.0) / 255.0,
                  alpha: 1.0)
    }
    
    convenience init(netHex:Int) {
        self.init(r:(netHex >> 16) & 0xff, g:(netHex >> 8) & 0xff, b:netHex & 0xff)
    }
    
}

extension UILabel {
    
    static func new(font: UIFont? = nil,
                    text: String? = "",
                    lines: Int = 0,
                    color: UIColor = .black,
                    alignment: NSTextAlignment = .center) -> UILabel {
        let tmp: UILabel = UILabel(frame: CGRect.zero)
        tmp.font = font
        tmp.text = text
        tmp.textColor = color
        tmp.numberOfLines = lines
        tmp.textAlignment = alignment
        tmp.backgroundColor = .clear
        tmp.sizeToFit()
        tmp.frame.size = CGSize(width: ceil(tmp.width), height: ceil(tmp.height))
        return tmp
    }
    
}

extension Int {
    
    var color: UIColor {
        return UIColor(netHex: self)
    }
    
    var scaled: CGFloat {
        return floor((CGFloat(self) / 375.0 * UIScreen.main.bounds.width))
    }
    
}

extension CGFloat {
    var scaled: CGFloat {
        return floor(self / 375.0 * UIScreen.main.bounds.width)
    }
}

extension Double {
    var scaled: CGFloat {
        return floor(CGFloat(self) / 375.0 * UIScreen.main.bounds.width)
    }
}


extension UIView {
    
    func shake() {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.07
        animation.repeatCount = 4
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: center.x - 10, y: center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: center.x + 10, y: center.y))
        layer.add(animation, forKey: "position")
    }
    
    var isVisible: Bool {
        get {
            return !isHidden
        }
        set {
            isHidden = !newValue
        }
    }
    
    var bottomGap: CGFloat {
        return window?.safeAreaInsets.bottom ?? 0.0
    }
    
    @nonobjc var origin: CGPoint {
        get {
            return self.frame.origin
        }
        set {
            self.frame.origin = newValue
        }
    }
    
    @nonobjc var width: CGFloat {
        get {
            return self.frame.width
        }
        set {
            self.frame.size.width = newValue
        }
    }
    
    @nonobjc var maxY: CGFloat {
        return self.frame.maxY
    }
    
    @nonobjc var maxX: CGFloat {
        return self.frame.maxX
    }
    
    @nonobjc var minX: CGFloat {
        return self.frame.minX
    }
    
    @nonobjc var minY: CGFloat {
        return self.frame.minY
    }
    
    @nonobjc var height: CGFloat {
        get {
            return self.frame.height
        }
        set {
            self.frame.size.height = newValue
        }
    }
    
    fileprivate struct AssociatedObjectKeys {
        static var tapGestureRecognizer = "MediaViewerAssociatedObjectKey_mediaViewer"
    }
    
    fileprivate typealias Action = (() -> Void)?
    
    fileprivate var tapGestureRecognizerAction: Action? {
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(self, &AssociatedObjectKeys.tapGestureRecognizer, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
            }
        }
        get {
            return objc_getAssociatedObject(self, &AssociatedObjectKeys.tapGestureRecognizer) as? Action
        }
    }
    
    @discardableResult
    public func tap(_ action: (() -> Void)?) -> Self {
        isUserInteractionEnabled   = true
        tapGestureRecognizerAction = action
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapGesture)))
        return self
    }
    
    @objc fileprivate func handleTapGesture(sender: UITapGestureRecognizer) {
        if let action = self.tapGestureRecognizerAction {
            action?()
        } else {
            print("no action")
        }
    }
    
    var hud: MBProgressHUD {
        (self.window ?? self)?.endEditing(true)
        return MBProgressHUD.showAdded(to: self, animated: true)
    }
    
}

extension String {
    
    func toData() -> Data {
        return decomposedStringWithCompatibilityMapping.data(using: .utf8)!
    }
    
    var loc: String {
        return NSLocalizedString(self, comment: "")
    }
    
    var url: URL? {
        return URL(string: self)
    }
    
    var trimmed: String {
        let gg = self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            .replacingOccurrences(of: "[0\\.]+$", with: "", options: .regularExpression)
        return gg.isEmpty ? "0" : gg
    }
    
    var withoutPrefix: String {
        if (starts(with: "0x")) {
            return replacingCharacters(in: startIndex ..< index(startIndex, offsetBy: 2), with: "")
        } else {
            return self
        }
    }
    
    mutating func removingRegexMatches(pattern: String, replaceWith: String = "") {
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options.caseInsensitive)
            let range = NSMakeRange(0, self.count)
            self = regex.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: replaceWith)
        } catch {
            return
        }
    }
    
    func show(in view: UIView? = nil, time: TimeInterval? = nil) {
        var hud: MBProgressHUD?
        if let v = view {
            hud = MBProgressHUD.showAdded(to: v, animated: true)
        } else if let w = (UIApplication.shared.delegate as? AppDelegate)?.window {
            hud = MBProgressHUD.showAdded(to: w, animated: true)
        }
        if let hud = hud {
            hud.mode = .text
            hud.label.text = self
            hud.label.numberOfLines = 0
            hud.hide(animated: true, afterDelay: time ?? 1.0)
        }
    }

    func heightFor(width: CGFloat, font: UIFont, lineBreak: NSLineBreakMode? = nil) -> CGFloat {
        let tmp = NSMutableParagraphStyle()
        tmp.setParagraphStyle(NSParagraphStyle.default)
        if let line = lineBreak {
            tmp.lineBreakMode = line
        }
        return self.boundingRect(with: CGSize(width: width, height: .greatestFiniteMagnitude),
                                 options: .usesLineFragmentOrigin,
                                 attributes: [.font: font, .paragraphStyle: tmp],
                                 context: nil).height
    }
    
    func width(with font: UIFont) -> CGFloat {
        return ceil(self.boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: font.lineHeight),
                                      options: .usesLineFragmentOrigin,
                                      attributes: [NSAttributedStringKey.font: font],
                                      context: nil).width)
    }
    
    func subscribe(_ target: Any?, with: Selector?) {
        if let t = target, let a = with {
            NotificationCenter.default.addObserver(t, selector: a, name: NSNotification.Name(rawValue: self), object: nil)
        }
    }
    
    func post(info: [String : Any] = [:]) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: self), object: nil, userInfo: info)
    }
    
    func post(object: Any?) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: self), object: object, userInfo: nil)
    }
}

struct Utils {
    
    public static let formatter: DateFormatter = {
        let tmp = DateFormatter()
        tmp.dateFormat = "dd.MM.yyyy HH:mm"
        return tmp
    }()
    
}
