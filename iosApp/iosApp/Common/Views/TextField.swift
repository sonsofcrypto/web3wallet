// Created by web3d3v on 12/04/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

class TextField: UITextField {

    var textChangeHandler: ((String?)->Void)?

    override var text: String? {
        didSet { textChangeHandler?(text) }
    }

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
    
    func configure() {
        font = Theme.font.body
        textColor = Theme.colour.labelPrimary
        rightView = makeClearButton()
        clipsToBounds = true
    }
}

private extension TextField {
    
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
            .init(systemName: "xmark.circle.fill"),
            for: .normal
        )
        button.tintColor = Theme.colour.labelSecondary
        button.addTarget(self, action: #selector(clearTapped), for: .touchUpInside)
        return button
    }
    
    @objc func clearTapped() {
        text = nil
    }
}
