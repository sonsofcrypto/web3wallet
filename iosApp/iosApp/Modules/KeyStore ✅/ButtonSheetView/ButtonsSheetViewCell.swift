// Created by web3d3v on 13/04/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

final class ButtonsSheetViewCell: UICollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    
    private var viewModel: KeyStoreViewModel.ButtonSheetViewModelButton?
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateButtonStyle()
    }
}

extension ButtonsSheetViewCell {
    
    func update(with viewModel: KeyStoreViewModel.ButtonSheetViewModelButton?) -> ButtonsSheetViewCell {
        self.viewModel = viewModel
        titleLabel.text = viewModel?.title ?? ""
        updateButtonStyle()
        return self
    }
}

private extension ButtonsSheetViewCell {
    
    func updateButtonStyle() {
        if viewModel?.type == .theNewMnemonic {
            applyPrimary()
        } else {
            applySecondary()
        }
    }
    
    func applyPrimary() {
        titleLabel.font = Theme.font.title3
        titleLabel.textColor = Theme.colour.buttonPrimaryText
        backgroundColor = Theme.colour.buttonBackgroundPrimary
        layer.cornerRadius = Theme.constant.cornerRadiusSmall
        layer.borderWidth = 0
    }
    
    func applySecondary() {
        titleLabel.font = Theme.font.title3
        titleLabel.textColor = Theme.colour.buttonSecondaryText
        backgroundColor = .clear
        layer.cornerRadius = Theme.constant.cornerRadiusSmall
        layer.borderColor = Theme.colour.buttonSecondaryText.cgColor
        layer.borderWidth = 1
    }
}
