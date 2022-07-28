// Created by web3d3v on 12/04/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

class TextField: UITextField {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }
    
    var placeholderAttrText: String? {
        
        get { attributedPlaceholder?.string }
        set {
            attributedPlaceholder = NSAttributedString(
                string: newValue ?? "",
                attributes: placeholder()
            )
        }
    }
}

private extension TextField {
    
    func configure() {
        
        font = Theme.font.body
        textColor = Theme.colour.labelPrimary
        rightView = makeClearButton()
        rightViewMode = .whileEditing
        clipsToBounds = true
    }
    
    func placeholder() -> [NSAttributedString.Key: Any] {
        [
            .font: font ?? Theme.font.body,
            .foregroundColor: Theme.colour.labelSecondary
        ]
    }
    
    func body() -> [NSAttributedString.Key: Any] {
        [
            .font: font ?? Theme.font.body,
            .foregroundColor: Theme.colour.labelPrimary,
            .shadow: textShadow(Theme.colour.fillSecondary)
        ]
    }
    
    func textShadow(_ tint: UIColor) -> NSShadow {
        let shadow = NSShadow()
        shadow.shadowOffset = .zero
        shadow.shadowBlurRadius = Theme.constant.cornerRadiusSmall.half
        shadow.shadowColor = tint
        return shadow
    }
    
    func makeClearButton() -> UIButton {
        
        let button = UIButton(type: .system)
        button.setImage(
            "xmark.circle.fill".assetImage,
            for: .normal
        )
        button.tintColor = Theme.colour.labelSecondary
        button.addTarget(self, action: #selector(clearTapped), for: .touchUpInside)
        button.addConstraints(
            [
                .layout(anchor: .widthAnchor, constant: .equalTo(constant: 20)),
                .layout(anchor: .heightAnchor, constant: .equalTo(constant: 20))
            ]
        )
        return button
    }
    
    @objc func clearTapped() {
        text = nil
    }
}
