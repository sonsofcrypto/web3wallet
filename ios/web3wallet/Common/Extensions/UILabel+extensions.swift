// Created by web3d3v on 14/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

extension UILabel {

    enum Style {
        case callout
        case smallLabel
        case smallBody
    }

    func applyStyle(_ style: Style) {
        switch style {
        case .callout:
            font = Theme.current.callout
            layer.applyShadow(Theme.current.tintSecondary)
            textColor = Theme.current.textColor
        case.smallLabel:
            font = Theme.current.footnote
            textColor = Theme.current.textColorSecondary
        case .smallBody:
            font = Theme.current.footnote
            textColor = Theme.current.textColorTertiary
        }
    }
}
