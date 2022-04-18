// Created by web3d3v on 13/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

class SettingsCell: CollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.textColor = ThemeOld.current.textColor
        titleLabel.font = ThemeOld.current.callout
        titleLabel.layer.shadowColor = ThemeOld.current.tintSecondary.cgColor
        titleLabel.layer.shadowOffset = .zero
        titleLabel.layer.shadowRadius = Global.shadowRadius
        titleLabel.layer.shadowOpacity = 1
    }

    func update(with viewModel: SettingsViewModel.Item?) -> SettingsCell {
        titleLabel.text = viewModel?.title() ?? ""

        return self
    }
}