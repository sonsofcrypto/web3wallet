// Created by web3d3v on 30/09/2023.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

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
        scale = 1
        layer.borderColor = Theme.color.collectionSectionStroke.cgColor
        layer.borderWidth = 1

        colorTint = Theme.color.bgPrimary
        blurRadius = Theme.padding
    }
}
