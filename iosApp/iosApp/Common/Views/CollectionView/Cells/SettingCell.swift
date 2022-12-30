// Created by web3d3v on 11/04/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

final class SettingCell: CollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!

    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        titleLabel.textColor = Theme.color.textPrimary
        titleLabel.font = Theme.font.callout
    }
}
