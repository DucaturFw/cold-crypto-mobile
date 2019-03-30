//
//  Gradient.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 03/03/2019.
//  Copyright © 2019 Kirill Kozhuhar. All rights reserved.
//

import UIKit

@IBDesignable
final class Gradient: UIView {
    
    // MARK: - Properties
    
    @IBInspectable
    var mainBackgroundColor: UIColor = UIColor.clear {
        didSet {
            updateColors()
        }
    }
    
    @IBInspectable
    var topBackgroundColor: UIColor = UIColor.white {
        didSet {
            updateColors()
        }
    }
    
    @IBInspectable
    var bottomBackgroundColor: UIColor = UIColor.white.withAlphaComponent(0.0) {
        didSet {
            updateColors()
        }
    }
    
    var gradientInsets = UIEdgeInsets.zero {
        didSet {
            setNeedsLayout()
        }
    }
    
    // MARK: - Private properties
    
    private lazy var gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.frame = self.bounds
        layer.isOpaque = false
        return layer
    }()
    
    // MARK: - Init & deinit
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds.inset(by: gradientInsets)
    }
    
    // MARK: - Private
    
    private func setup() {
        layer.insertSublayer(gradientLayer, at: 0)
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        
        updateColors()
    }
    
    private func updateColors() {
        gradientLayer.colors = [topBackgroundColor.cgColor, bottomBackgroundColor.cgColor]
        backgroundColor = mainBackgroundColor
    }
}
