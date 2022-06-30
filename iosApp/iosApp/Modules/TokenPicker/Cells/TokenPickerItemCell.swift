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
    
    @IBOutlet weak var tokenPriceStackView: UIStackView!
    @IBOutlet weak var tokenLabel: UILabel!
    @IBOutlet weak var tokenSymbolLabel: UILabel!
    @IBOutlet weak var usdPriceLabel: UILabel!

    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        iconImageView.layer.cornerRadius = iconImageView.frame.size.width * 0.5
        iconImageView.backgroundColor = Theme.colour.labelPrimary
                        
        nameLabel.applyStyle(.body)
        nameLabel.textColor = Theme.colour.labelPrimary
        
        symbolLabel.applyStyle(.callout)
        symbolLabel.textColor = Theme.colour.labelSecondary

        networkLabel.applyStyle(.smallLabel)
        networkLabel.textColor = Theme.colour.labelTertiary
        
        multiSelectTick.isHidden = true
        
        tokenPriceStackView.isHidden = true
        tokenLabel.applyStyle(.body)
        tokenLabel.textAlignment = .right
        tokenSymbolLabel.applyStyle(.bodyGlow)
        tokenSymbolLabel.textAlignment = .right
        tokenSymbolLabel.addConstraints(
            [
                .hugging(layoutAxis: .horizontal, priority: .required)
            ]
        )
        usdPriceLabel.applyStyle(.smallBody)
        usdPriceLabel.textAlignment = .right
    }

    func update(
        with viewModel: TokenPickerViewModel.Token,
        and width: CGFloat
    ) {

        iconImageView.image = viewModel.image
        symbolLabel.text = viewModel.symbol
        nameLabel.text = viewModel.name
        networkLabel.text = viewModel.network
        
        switch viewModel.type {
            
        case .receive:
            break

        case let .multiSelect(isSelected):
            multiSelectTick.isHidden = false
            multiSelectTick.tintColor = isSelected ? Theme.colour.systemOrange : Theme.colour.fillTertiary

        case let .send(tokens, usdTotal):
            symbolLabel.isHidden = true
            tokenPriceStackView.isHidden = false
            tokenLabel.text = tokens
            tokenSymbolLabel.text = viewModel.symbol
            usdPriceLabel.text = usdTotal
        }
        
        widthLayoutConstraint.constant = width
    }
}
