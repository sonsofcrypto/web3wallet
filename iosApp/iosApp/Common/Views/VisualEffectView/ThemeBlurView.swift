// Created by web3d3v on 30/09/2023.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

@IBDesignable
class ThemeBlurView: VisualEffectView {
    
    override init(effect: UIVisualEffect?) {
        super.init(effect: effect)
        configureUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureUI()
    }

    func configureUI() {
        applyTheme(Theme)
    }

    func applyTheme(_ theme: ThemeProtocol) {
        colorTint = theme.color.bgPrimary
        colorTintAlpha = theme.blurTintAlpha
        blurRadius = theme.blurRadius
        scale = 1
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        colorTint = .white
        colorTintAlpha = 0.18
        blurRadius = 16
        scale = 1
    }
}
