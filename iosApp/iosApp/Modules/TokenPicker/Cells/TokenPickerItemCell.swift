// Created by web3d4v on 12/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

final class TokenPickerItemCell: UICollectionViewCell {
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var networkLabel: UILabel!
    @IBOutlet weak var widthLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var multiSelectTick: UIImageView!

    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        iconImageView.layer.cornerRadius = iconImageView.frame.size.width * 0.5
        iconImageView.backgroundColor = Theme.color.text
                        
        nameLabel.applyStyle(.body)
        nameLabel.textColor = Theme.color.text
        
        symbolLabel.applyStyle(.callout)
        symbolLabel.textColor = Theme.color.textSecondary

        networkLabel.applyStyle(.smallLabel)
        networkLabel.textColor = Theme.color.textTertiary
    }

    func update(
        with viewModel: TokenPickerViewModel.Token,
        and width: CGFloat
    ) {

        iconImageView.image = viewModel.image
        symbolLabel.text = viewModel.symbol
        nameLabel.text = viewModel.name
        networkLabel.text = viewModel.network
        multiSelectTick.isHidden = !viewModel.isSelected
        
        widthLayoutConstraint.constant = width
    }
}
