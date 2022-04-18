// Created by web3d3v on 12/04/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

class TextField: UITextField {

    var defaultPlaceholderAttributes = ThemeOld.current.placeholderTextAttributes()

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
                attributes: defaultPlaceholderAttributes
            )
        }
    }
    
    func configure() {
        defaultTextAttributes = ThemeOld.current.bodyTextAttributes()
        typingAttributes = ThemeOld.current.bodyTextAttributes()
        backgroundColor = ThemeOld.current.backgroundDark.withAlphaComponent(0.25)
        clipsToBounds = true
        layer.applyBorder(ThemeOld.current.tintPrimaryLight)
        layer.cornerRadius = Global.cornerRadius
    }
}
