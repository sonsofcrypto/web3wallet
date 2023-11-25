// Created by web3d3v on 13/04/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

final class ButtonCell: UICollectionViewCell {
    private lazy var button: Button = {
        let button = Button(frame: bounds)
        button.isUserInteractionEnabled = false
        addSubview(button)
        return button
    }()

    override func layoutSubviews() {
        super.layoutSubviews()
        button.frame = bounds
    }
}

extension ButtonCell {

    func update(with viewModel: ButtonViewModel) -> Self {
        button.update(with: viewModel)
        return self
    }
}

final class ButtonsSheetViewCell: UICollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    
    private var viewModel: SignersViewModel.ButtonSheetViewModelButton?
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateButtonStyle()
    }
}

extension ButtonsSheetViewCell {
    
    func update(with viewModel: SignersViewModel.ButtonSheetViewModelButton?) -> ButtonsSheetViewCell {
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
        titleLabel.textColor = Theme.color.textPrimary
        backgroundColor = Theme.color.buttonBgPrimary
        layer.cornerRadius = Theme.cornerRadius.half
        layer.borderWidth = 0
    }
    
    func applySecondary() {
        titleLabel.font = Theme.font.title3
        titleLabel.textColor = Theme.color.textPrimary
        backgroundColor = .clear
        layer.cornerRadius = Theme.cornerRadius.half
        layer.borderColor = Theme.color.textPrimary.cgColor
        layer.borderWidth = 1
    }
}
