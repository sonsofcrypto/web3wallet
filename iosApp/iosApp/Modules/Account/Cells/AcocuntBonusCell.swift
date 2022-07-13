// Created by web3d3v on 13/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

final class AccountBonusCell: CollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.applyStyle(.callout)
        layer.cornerRadius = Theme.constant.cornerRadiusSmall * 2
    }

    override func prepareForReuse() {
        super.prepareForReuse()
    }
}
