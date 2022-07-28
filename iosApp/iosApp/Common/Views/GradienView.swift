// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

/// Convenience `UIView` wrapper for `CAGradientLayer`. Main goal to easily show
/// stuble shadows without having to add assets to the app. `UIView` wrapper
/// is handy as it avoids having to deal with more cumbersome `CALayer` layout
@IBDesignable
final class GradientView: UIView {
    
    enum Direction {
        case vertical
        case horizontal
        case custom(CGPoint, CGPoint)
    }
    
    init() {
        super.init(frame: .zero)
        configureUI()
    }
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        
        super.init(coder: coder)
        
        configureUI()
    }
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        configureUI()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        
        super.traitCollectionDidChange(previousTraitCollection)
        
        configureUI()
    }
    
    /// Defining the color of each gradient * stop. Defaults to nil. Animatable.
    var colors: [UIColor] {
        get {
            let cgColors = (layer as? CAGradientLayer)?.colors as? [CGColor]
            return cgColors?.compactMap { UIColor(cgColor: $0) } ?? []
        }
        set {
            (layer as? CAGradientLayer)?.colors = newValue.map { $0.cgColor }
        }
    }
    
    var isDashboard: Bool = false {
        
        didSet {
            
            configureUI()
        }
    }
    
    /// Defines direction of gradient in `CAGradientLayer`
    var direction: Direction = .horizontal {
        didSet {
            switch direction {
            case .vertical:
                (layer as? CAGradientLayer)?.startPoint = CGPoint(x: 0, y: 0)
                (layer as? CAGradientLayer)?.endPoint = CGPoint(x: 0, y: 1)
            case .horizontal:
                (layer as? CAGradientLayer)?.startPoint = CGPoint(x: 0, y: 0.5)
                (layer as? CAGradientLayer)?.endPoint = CGPoint(x: 1, y: 0.5)
            case .custom(let startPoint, let endPoint):
                (layer as? CAGradientLayer)?.startPoint = startPoint
                (layer as? CAGradientLayer)?.endPoint = endPoint
            }
        }
    }
    
//    @IBInspectable
//    var defaultTopColor: UIColor = defaultShadowColors().first! {
//        didSet { colors = [defaultTopColor, defaultBottomColor] }
//    }
//    
//    @IBInspectable
//    var defaultBottomColor: UIColor = defaultShadowColors().last! {
//        didSet { colors = [defaultTopColor, defaultBottomColor] }
//    }
    
    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    /// two black colors with aplha at 0 and 0.25
    class func defaultShadowColors() -> [UIColor] {
        return [UIColor.black.withAlphaComponent(0), UIColor.black.withAlphaComponent(0.25)]
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
    }
}

private extension GradientView {
    
    func configureUI() {
        
        switch Theme.type {
            
        case .themeA:

            let topColor = Theme.colour.gradientTop
//            let middleTopColor = isDarkMode ? UIColor(rgb: 0xDA3E9B) : UIColor(rgb: 0x4361BC).withAlpha(0.75)
//            let middleColor = isDarkMode ? UIColor(rgb: 0xC939AA) : UIColor(rgb: 0xBE6CF4).withAlpha(0.75)
//            let middleBottomColor = isDarkMode ? UIColor(rgb: 0xAC36B0) : UIColor(rgb: 0xFC78A9).withAlpha(0.71)
            let bottomColor = Theme.colour.gradientBottom
            
            if isDashboard {
                colors = [
                    topColor, bottomColor
                ]
                //(layer as? CAGradientLayer)?.locations = [0,0.3,0.375,0.5,0.75,1]
            } else {
                colors = [
                    topColor, bottomColor
                ]
                //(layer as? CAGradientLayer)?.locations = [0,0.3,0.5,0.75,1]
            }
            
        case .themeIOS:
            colors = [
                Theme.colour.gradientTop, Theme.colour.gradientBottom
            ]
        }
    }
}
