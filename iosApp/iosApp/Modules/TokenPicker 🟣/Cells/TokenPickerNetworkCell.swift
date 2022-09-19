// Created by web3d4v on 08/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

final class TokenPickerNetworkCell: CollectionViewCell {
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        clipsToBounds = false
        backgroundColor = Theme.colour.cellBackground
        layer.borderColor = Theme.colour.labelPrimary.cgColor
        iconImageView.backgroundColor = Theme.colour.labelPrimary
        iconImageView.layer.cornerRadius = 15
        nameLabel.font = Theme.font.body
    }
    
    func update(with viewModel: TokenPickerViewModel.Network) {
        iconImageView.image = viewModel.iconName.assetImage
        nameLabel.text = viewModel.name
        layer.borderWidth = viewModel.isSelected ? 1.0 : 0.0
        nameLabel.textColor = viewModel.isSelected ? Theme.colour.labelPrimary : Theme.colour.labelSecondary
    }
}
