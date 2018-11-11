//
//  ScanView.swift
//  MultiMask
//
//  Created by Kirill Kozhuhar on 03/09/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import UIKit

class ScanView : UIView {
    
    private let lineLayer = CAShapeLayer()
    
    private let pathAnimation = CABasicAnimation(keyPath: "path")
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
        clearsContextBeforeDrawing = true
        
        lineLayer.fillColor   = UIColor.clear.cgColor
        lineLayer.strokeColor = 0x1888FE.color.cgColor
        lineLayer.lineWidth   = 2.0
        lineLayer.shadowColor   = 0x1888FE.color.cgColor
        lineLayer.shadowOffset  = CGSize(width: 0, height: 0)
        lineLayer.shadowOpacity = 0.8
        lineLayer.shadowRadius  = 6.0
        layer.addSublayer(lineLayer)
    }
    
    func pause() {
        let pausedTime = lineLayer.convertTime(CACurrentMediaTime(), from: nil)
        lineLayer.speed = 0.0
        lineLayer.timeOffset = pausedTime
    }
    
    func resume() {
        let pausedTime = lineLayer.timeOffset
        lineLayer.speed = 1.0
        lineLayer.timeOffset = 0.0
        lineLayer.beginTime = 0.0
        lineLayer.beginTime = lineLayer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    private var side: CGFloat {
        return min(width, height) - 40.0
    }
    
    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }

        ctx.setFillColor(UIColor.black.withAlphaComponent(0.3).cgColor)
        ctx.fill(bounds)

        

        let p = UIBezierPath(roundedRect: CGRect(x: (width - side)/2.0, y: (height - side)/2.0, width: side, height: side),
                             byRoundingCorners: UIRectCorner.allCorners,
                             cornerRadii: CGSize(width: 6.0, height: 6.0))

        ctx.addPath(p.cgPath)

        ctx.saveGState()
        ctx.setBlendMode(CGBlendMode.clear)
        ctx.drawPath(using: CGPathDrawingMode.fill)
        ctx.restoreGState()

        ctx.addPath(p.cgPath)
        ctx.setStrokeColor(0x1888FE.color.cgColor)
        ctx.setLineWidth(2)
        ctx.strokePath()
    }
    
    func getTo() -> CGPath {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: side - 10))
        path.addLine(to: CGPoint(x: side, y: side - 10))
        return path
    }
    
    func getFrom() -> CGPath {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: 10))
        path.addLine(to: CGPoint(x: side, y: 10))
        return path
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        lineLayer.frame = CGRect(x: (width - side)/2.0, y: (height - side)/2.0, width: side, height: side)
        
        pathAnimation.toValue   = getTo()
        pathAnimation.fromValue = getFrom()
        pathAnimation.duration  = 2.0
        pathAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        pathAnimation.repeatCount = .infinity
        pathAnimation.isRemovedOnCompletion = false
        pathAnimation.autoreverses = true
        
        lineLayer.path = getFrom()
        lineLayer.removeAllAnimations()
        lineLayer.add(pathAnimation, forKey: "pathAnimation")
    }
    
}
