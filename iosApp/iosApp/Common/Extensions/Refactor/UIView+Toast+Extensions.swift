// Created by web3d4v on 15/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

extension UIView {
    
    private static let toastViewTag = 4323425234
    
    var isToastFailurePresented: Bool {
        
        subviews.first { $0.tag == Self.toastViewTag } != nil
    }
    
    func presentToastAlert(
        with message: String,
        textAlignment: NSTextAlignment = .center,
        duration: TimeInterval = 2.0,
        bottomOffset: CGFloat = 48
    ) {
        subviews.forEach {
            if $0.tag == Self.toastViewTag { $0.removeFromSuperview() }
        }

        let size = CGSize(width: bounds.width - Theme.padding * 2, height: 48)
        let toastView = UIView(frame: .init(origin: .zero, size: size))
        toastView.tag = Self.toastViewTag
        toastView.alpha = 0.0
        toastView.autoresizingMask = [.flexibleWidth]

        let backgroundView = UIView()
        backgroundView.layer.cornerRadius = Theme.cornerRadiusSmall
        backgroundView.backgroundColor = Theme.color.tabBarBackground
        toastView.addSubview(backgroundView)
        backgroundView.frame = toastView.bounds
        backgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        let label = UILabel()
        label.apply(style: .subheadline)
        label.textColor = Theme.color.textPrimary
        label.textAlignment = textAlignment
        label.numberOfLines = 0
        label.text = message
        backgroundView.addSubview(label)
        label.frame = backgroundView.bounds.insetBy(dx: Theme.padding * 0.75, dy: Theme.padding)
        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        addSubview(toastView)

        toastView.frame = CGRect(
            origin: .init(x: Theme.padding, y: bounds.maxY - (size.height + bottomOffset)),
            size: size
        )

        UIView.springAnimate(
            0.3,
            animations: { toastView.alpha = 1.0 },
            completion: { _ in
                UIView.springAnimate(
                    0.3,
                    delay: duration,
                    animations: { toastView.alpha = 0 },
                    completion: { _ in toastView.removeFromSuperview() }
                )
            }
        )
    }
}
