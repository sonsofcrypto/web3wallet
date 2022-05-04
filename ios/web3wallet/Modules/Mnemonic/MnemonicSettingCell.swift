// Created by web3d3v on 11/04/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

class MnemonicSettingCell: CollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.textColor = Theme.current.textColor
        titleLabel.font = Theme.current.callout
        titleLabel.layer.shadowColor = Theme.current.tintSecondary.cgColor
        titleLabel.layer.shadowOffset = .zero
        titleLabel.layer.shadowRadius = Global.shadowRadius
        titleLabel.layer.shadowOpacity = 1
    }
}