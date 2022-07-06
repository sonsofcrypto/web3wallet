// Created by web3d4v on 12/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

final class TokenPickerItemCell: UICollectionViewCell {
    
    @IBOutlet weak var separatorTopView: UIView!
    @IBOutlet weak var separatorTopViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var separatorTopViewTrailingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var networkLabel: UILabel!
    
    @IBOutlet weak var multiSelectView: UIView!
    @IBOutlet weak var multiSelectTick: UIImageView!
    
    @IBOutlet weak var tokenPriceStackView: UIStackView!
    @IBOutlet weak var tokenLabel: UILabel!
    @IBOutlet weak var tokenSymbolLabel: UILabel!
    @IBOutlet weak var usdPriceLabel: UILabel!
    
    @IBOutlet weak var separatorBottomView: UIView!

    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        iconImageView.backgroundColor = Theme.colour.labelPrimary
        iconImageView.layer.cornerRadius = 15

        nameLabel.font = Theme.font.body
        nameLabel.textColor = Theme.colour.labelPrimary
        
        symbolLabel.font = Theme.font.body
        symbolLabel.textColor = Theme.colour.labelSecondary

        networkLabel.font = Theme.font.callout
        networkLabel.textColor = Theme.colour.labelSecondary
        
        multiSelectView.isHidden = true
        
        tokenPriceStackView.isHidden = true
        tokenLabel.font = Theme.font.body
        tokenLabel.textColor = Theme.colour.labelPrimary
        tokenLabel.textAlignment = .right
        tokenSymbolLabel.font = Theme.font.callout
        tokenSymbolLabel.textColor = Theme.colour.labelSecondary
        tokenSymbolLabel.textAlignment = .right
        tokenSymbolLabel.addConstraints(
            [
                .hugging(layoutAxis: .horizontal, priority: .required)
            ]
        )
        usdPriceLabel.font = Theme.font.callout
        usdPriceLabel.textColor = Theme.colour.labelSecondary
        usdPriceLabel.textAlignment = .right
        
        separatorTopView.backgroundColor = Theme.colour.separatorNoTransparency
        separatorBottomView.backgroundColor = Theme.colour.separatorNoTransparency
    }

    func update(
        with viewModel: TokenPickerViewModel.Token
    ) {

        iconImageView.image = viewModel.image
        symbolLabel.text = viewModel.symbol
        nameLabel.text = viewModel.name
        if let network = viewModel.network {
            networkLabel.isHidden = true
            networkLabel.text = network
        } else {
            networkLabel.isHidden = true
        }
        
        switch viewModel.type {
            
        case .receive:
            break

        case let .multiSelect(isSelected):
            multiSelectView.isHidden = false
            multiSelectTick.tintColor = Theme.colour.labelSecondary
            multiSelectTick.image = isSelected ? .init(systemName: "checkmark.circle.fill") : .init(systemName: "circle")

        case let .send(tokens, usdTotal):
            symbolLabel.isHidden = true
            tokenPriceStackView.isHidden = false
            tokenLabel.text = tokens
            tokenSymbolLabel.text = viewModel.symbol
            usdPriceLabel.text = usdTotal
        }
        
        switch viewModel.position {
        case .onlyOne:
            separatorTopView.isHidden = false
            separatorTopViewLeadingConstraint.constant = 0
            separatorTopViewTrailingConstraint.constant = 0
            separatorBottomView.isHidden = false
        case .first:
            separatorTopView.isHidden = false
            separatorTopViewLeadingConstraint.constant = 0
            separatorTopViewTrailingConstraint.constant = 0
            separatorBottomView.isHidden = true
        case .middle:
            separatorTopView.isHidden = false
            separatorTopViewLeadingConstraint.constant = Theme.constant.padding
            separatorTopViewTrailingConstraint.constant = Theme.constant.padding
            separatorBottomView.isHidden = true
        case .last:
            separatorTopView.isHidden = false
            separatorTopViewLeadingConstraint.constant = Theme.constant.padding
            separatorTopViewTrailingConstraint.constant = Theme.constant.padding
            separatorBottomView.isHidden = false
        }
    }
}
