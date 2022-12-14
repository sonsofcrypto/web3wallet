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
        
        let toastView = UIView()
        toastView.tag = Self.toastViewTag
        toastView.alpha = 0.0

        let backgroundView = UIView()
        backgroundView.layer.cornerRadius = Theme.constant.cornerRadiusSmall
        backgroundView.backgroundColor = Theme.color.tabBarBackground
        toastView.addSubview(backgroundView)
        backgroundView.addConstraints(
            [
                .layout(anchor: .centerXAnchor),
                .layout(anchor: .topAnchor),
                .layout(anchor: .bottomAnchor),
                .layout(
                    anchor: .leadingAnchor,
                    constant: .greaterThanOrEqualTo(
                        constant: Theme.constant.padding
                    ),
                    priority: .defaultHigh
                ),
                .layout(
                    anchor: .trailingAnchor,
                    constant: .greaterThanOrEqualTo(constant: Theme.constant.padding),
                    priority: .defaultHigh
                )
            ]
        )

        let label = UILabel()
        label.apply(style: .subheadline)
        label.textColor = Theme.color.textPrimary
        label.textAlignment = textAlignment
        label.numberOfLines = 0
        label.text = message
        backgroundView.addSubview(label)
        label.addConstraints(
            [
                .layout(
                    anchor: .leadingAnchor,
                    constant: .equalTo(constant: Theme.constant.padding)
                ),
                .layout(
                    anchor: .trailingAnchor,
                    constant: .equalTo(constant: Theme.constant.padding)
                ),
                .layout(
                    anchor: .topAnchor,
                    constant: .equalTo(constant: Theme.constant.padding * 0.75)),
                .layout(
                    anchor: .bottomAnchor,
                    constant: .equalTo(constant: Theme.constant.padding * 0.75)
                )
            ]
        )
            
        addSubview(toastView)
        toastView.addConstraints(
            [
                .layout(
                    anchor: .leadingAnchor,
                    constant: .equalTo(constant: Theme.constant.padding)
                ),
                .layout(
                    anchor: .trailingAnchor,
                    constant: .equalTo(constant: Theme.constant.padding)
                ),
                .layout(anchor: .bottomAnchor, constant: .equalTo(constant: bottomOffset))
            ]
        )

        UIView.animate(
            withDuration: 0.3,
            animations: {
                toastView.alpha = 1.0
            },
            completion: { _ in
                
                toastView.animateOut(with: duration)
            }
        )
    }
}

private extension UIView {
    
    func animateOut(with duration: TimeInterval) {
        
        UIView.animate(
            withDuration: 0.3,
            delay: duration,
            options: .curveEaseInOut,
            animations: { [weak self] in
                guard let self = self else { return }
                self.alpha = 0.0
            },
            completion: { [weak self] _ in
                guard let self = self else { return }
                self.removeFromSuperview()
            }
        )
    }
}
