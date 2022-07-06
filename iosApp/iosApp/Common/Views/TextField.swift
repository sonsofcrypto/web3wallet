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
    
    func configure() {
        defaultTextAttributes = body()
        typingAttributes = body()
        backgroundColor = Theme.colour.backgroundBasePrimary.withAlphaComponent(0.25)
        clipsToBounds = true
        layer.applyBorder(Theme.colour.fillTertiary)
        layer.cornerRadius = Global.cornerRadius
    }
}

private extension TextField {
    
    func placeholder() -> [NSAttributedString.Key: Any] {
        [
            .font: Theme.font.subheadline,
            .foregroundColor: Theme.colour.labelTertiary,
        ]
    }
    
    func body() -> [NSAttributedString.Key: Any] {
        [
            .font: Theme.font.body,
            .foregroundColor: Theme.colour.labelPrimary,
            .shadow: textShadow(Theme.colour.fillSecondary)
        ]
    }
    
    func textShadow(_ tint: UIColor) -> NSShadow {
        
        let shadow = NSShadow()
        shadow.shadowOffset = .zero
        shadow.shadowBlurRadius = Global.shadowRadius
        shadow.shadowColor = tint
        return shadow
    }
}
