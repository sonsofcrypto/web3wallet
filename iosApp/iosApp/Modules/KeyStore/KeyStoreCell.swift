// Created by web3d3v on 13/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

final class KeyStoreCell: CollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var accessoryButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.applyStyle(.callout)
        accessoryButton.tintColor = Theme.colour.labelTertiary
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        accessoryButton.removeAllTargets()
    }
}
