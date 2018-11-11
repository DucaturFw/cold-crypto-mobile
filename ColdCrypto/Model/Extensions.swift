//
//  Extensions.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 20/10/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import MBProgressHUD
import Foundation
import HandyJSON
import UIKit
import SideMenu

extension UIFont {
    
    static func sfProMedium(_ size: CGFloat) -> UIFont {
        return UIFont(name: "SFProDisplay-Medium", size: size) ?? UIFont.boldSystemFont(ofSize: size)
    }
    
    static func hnRegular(_ size: CGFloat) -> UIFont {
        return UIFont(name: "HelveticaNeue", size: size) ?? UIFont.systemFont(ofSize: size)
    }
    
    static func sfProSemibold(_ size: CGFloat) -> UIFont {
        return UIFont(name: "SFProDisplay-Semibold", size: size) ?? UIFont.boldSystemFont(ofSize: size)
    }
    
    static func hnMedium(_ size: CGFloat) -> UIFont {
        return UIFont(name: "HelveticaNeue-Medium", size: size) ?? UIFont.boldSystemFont(ofSize: size)
    }
    
    static func hnBold(_ size: CGFloat) -> UIFont {
        return UIFont(name: "HelveticaNeue-Bold", size: size) ?? UIFont.boldSystemFont(ofSize: size)
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

protocol HasApply {}

extension HasApply {
    @discardableResult
    func apply(_ block: (Self)->Void) -> Self {
        block(self)
        return self
    }
}

extension UIViewController: HasApply {}

extension UIView: HasApply {

    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
    
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
        addTint()
        if let action = self.tapGestureRecognizerAction {
            action?()
        } else {
            print("no action")
        }
    }
    
    func addTint(_ time: Int = 100, completion: (()->Void)? = nil) {
        let tmp = UIView(frame: bounds)
        tmp.backgroundColor = .black
        tmp.alpha = 0.1
        tmp.mask = self.snapshotView(afterScreenUpdates: true)
        tmp.isUserInteractionEnabled = false
        tmp.tag = 105365
        if let v = viewWithTag(tmp.tag) {
            v.removeFromSuperview()
        }
        addSubview(tmp)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + DispatchTimeInterval.milliseconds(time)) {
            tmp.removeFromSuperview()
            completion?()
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
                                      attributes: [.font: font],
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

extension URL {
    public var allParams: [String: String] {
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: true), let queryItems = components.queryItems else {
            return [:]
        }
        var parameters = [String: String]()
        for item in queryItems {
            parameters[item.name] = item.value
        }
        return parameters
    }
    
    @discardableResult
    func append(_ queryItem: String, value: String?) -> URL {
        guard var urlComponents = URLComponents(string:  absoluteString) else { return absoluteURL }
        
        // create array of existing query items
        var queryItems: [URLQueryItem] = urlComponents.queryItems ??  []
        
        // create query item if value is not nil
        guard let value = value else { return absoluteURL }
        let queryItem = URLQueryItem(name: queryItem, value: value)
        
        // append the new query item in the existing query items array
        queryItems.append(queryItem)
        
        // append updated query items array in the url component object
        urlComponents.queryItems = queryItems// queryItems?.append(item)
        
        if let ff = urlComponents.url {
            return ff
        }
        return absoluteURL
    }
    
}

extension HandyJSON {
    @discardableResult
    func apply(_ block: (Self)->Void) -> Self {
        block(self)
        return self
    }
}

extension UIViewController: UISideMenuNavigationControllerDelegate {

    @objc public func sideMenuWillAppear(menu: UISideMenuNavigationController, animated: Bool) {
        sideMenuWillAppear(animated: animated)
    }
    
    @objc public func sideMenuDidAppear(menu: UISideMenuNavigationController, animated: Bool) {
        sideMenuDidAppear(animated: animated)
    }
    
    @objc public func sideMenuWillDisappear(menu: UISideMenuNavigationController, animated: Bool) {
        sideMenuWillDisappear(animated: animated)
    }
    
    @objc public func sideMenuDidDisappear(menu: UISideMenuNavigationController, animated: Bool) {
        sideMenuDidDisappear(animated: animated)
    }
    
    @objc public func sideMenuWillAppear(animated: Bool) {}
    
    @objc public func sideMenuDidAppear(animated: Bool) {}
    
    @objc public func sideMenuWillDisappear(animated: Bool) {}
    
    @objc public func sideMenuDidDisappear(animated: Bool) {}
    
}

protocol ReusableForTable: class { }

extension ReusableForTable {
    
    static func register(in table: UITableView) {
        table.register(self, forCellReuseIdentifier: ObjectIdentifier(self).debugDescription)
    }
    
    static func get(from table: UITableView, at position: IndexPath) -> Self {
        return table.dequeueReusableCell(withIdentifier: ObjectIdentifier(self).debugDescription, for: position) as! Self
    }
    
}

extension UITableViewCell: ReusableForTable {}

protocol ReusableForCollection: class { }

extension ReusableForCollection {
    
    static func register(in table: UICollectionView) {
        table.register(self, forCellWithReuseIdentifier: ObjectIdentifier(self).debugDescription)
    }
    
    static func get(from table: UICollectionView, at position: IndexPath) -> Self {
        return table.dequeueReusableCell(withReuseIdentifier: ObjectIdentifier(self).debugDescription, for: position) as! Self
    }
    
}

extension UICollectionViewCell: ReusableForCollection {}

class MyBlockiesHelper {
    
    /**
     * Creates the initial version of the 4 UInt32 array for the given seed.
     * The result is equal for equal seeds.
     *
     * - parameter seed: The seed.
     *
     * - returns: The UInt32 array with exactly 4 values stored in it.
     */
    static func createRandSeed(seed: String) -> [UInt32] {
        var randSeed = [UInt32](repeating: 0, count: 4)
        for i in 0 ..< seed.count {
            // &* and &- are the "overflow" operators. Need to be used there.
            // There is no overflow left shift operator so we do "&* pow(2, 5)" instead of "<< 5"
            randSeed[i % 4] = ((randSeed[i % 4] &* (2 << 4)) &- randSeed[i % 4])
            let index = seed.index(seed.startIndex, offsetBy: i)
            randSeed[i % 4] = randSeed[i % 4] &+ seed[index].asciiValue
        }
        
        return randSeed
    }
}

extension Character {
    
    /**
     * Returns the value of the first 8 bits of this unicode character.
     * This is a correct ascii representation of this character if it is
     * an ascii character.
     */
    var asciiValue: UInt32 {
        get {
            let s = String(self).unicodeScalars
            return s[s.startIndex].value
        }
    }
}

extension Decimal {
    private static let formatter: NumberFormatter = {
        let tmp = NumberFormatter()
        tmp.minimumFractionDigits = 0
        tmp.minimumFractionDigits = 5
        tmp.minimumIntegerDigits  = 1
        tmp.decimalSeparator = "."
        return tmp
    }()
    
    var compactValue: String? {
        return Decimal.formatter.string(for: self)
    }
}
