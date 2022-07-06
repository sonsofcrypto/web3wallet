// Created by web3d4v on 15/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

extension UIView {
    
    func presentToastAlert(
        with message: String,
        bottomOffset: CGFloat = 48
    ) {
        
        let toastView = UIView()
        toastView.alpha = 0.0

        let backgroundView = UIView()
        backgroundView.layer.cornerRadius = 8
        backgroundView.backgroundColor = Theme.colour.navBarBackground
        toastView.addSubview(backgroundView)
        backgroundView.addConstraints(
            [
                .layout(anchor: .centerXAnchor),
                .layout(anchor: .topAnchor),
                .layout(anchor: .bottomAnchor)
            ]
        )

        let label = UILabel()
        label.font = Theme.font.body
        label.textColor = Theme.colour.labelPrimary
        label.numberOfLines = 0
        label.text = message
        backgroundView.addSubview(label)
        label.addConstraints(
            [
                .layout(anchor: .leadingAnchor, constant: .equalTo(constant: 16)),
                .layout(anchor: .trailingAnchor, constant: .equalTo(constant: 16)),
                .layout(anchor: .topAnchor, constant: .equalTo(constant: 12)),
                .layout(anchor: .bottomAnchor, constant: .equalTo(constant: 12))
            ]
        )
            
        addSubview(toastView)
        toastView.addConstraints(
            [
                .layout(anchor: .leadingAnchor, constant: .equalTo(constant: 16)),
                .layout(anchor: .trailingAnchor, constant: .equalTo(constant: 16)),
                .layout(anchor: .bottomAnchor, constant: .equalTo(constant: bottomOffset))
            ]
        )

        UIView.animate(
            withDuration: 0.3,
            animations: {
                toastView.alpha = 1.0
            },
            completion: { _ in
                
                toastView.animateOut()
            }
        )
    }
}

private extension UIView {
    
    func animateOut() {
        
        UIView.animate(
            withDuration: 0.3,
            delay: 1.0,
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
