// Created by web3d4v on 12/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

final class CurrencyPickerTokenCell: UICollectionViewCell {
    @IBOutlet weak var separatorTopView: UIView!
    @IBOutlet weak var separatorTopViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var separatorTopViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var multiSelectView: UIView!
    @IBOutlet weak var multiSelectTick: UIImageView!
    @IBOutlet weak var tokenPriceView: UIView!
    @IBOutlet weak var tokenLabel: UILabel!
    @IBOutlet weak var usdPriceLabel: UILabel!
    @IBOutlet weak var separatorBottomView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        iconImageView.backgroundColor = Theme.color.textPrimary
        iconImageView.layer.cornerRadius = 15
        nameLabel.font = Theme.font.body
        nameLabel.textColor = Theme.color.textPrimary
        symbolLabel.font = Theme.font.body
        symbolLabel.textColor = Theme.color.textSecondary
        multiSelectView.isHidden = true
        tokenPriceView.isHidden = true
        tokenLabel.font = Theme.font.body
        tokenLabel.textColor = Theme.color.textPrimary
        tokenLabel.textAlignment = .right
        usdPriceLabel.textAlignment = .right
    }

    func update(with viewModel: CurrencyPickerViewModel.Currency) {
        iconImageView.image = UIImage(named: viewModel.imageName)
        symbolLabel.text = viewModel.symbol.uppercased()
        nameLabel.text = viewModel.name
        updateIsSelected(with: viewModel.isSelected?.boolValue)
        updateTokens(with: viewModel)
        updateSeparator(with: viewModel.position)
    }
}

private extension CurrencyPickerTokenCell {
    
    func updateIsSelected(with isSelected: Bool?) {
        if let isSelected = isSelected {
            multiSelectView.isHidden = false
            multiSelectTick.tintColor = Theme.color.textSecondary
            multiSelectTick.image = UIImage(
                systemName: isSelected ? "checkmark.circle.fill" : "circle"
            )
        } else {
            multiSelectView.isHidden = true
        }
    }
    
    func updateTokens(with viewModel: CurrencyPickerViewModel.Currency) {
        if let tokens = viewModel.tokens, let fiat = viewModel.fiat {
            symbolLabel.isHidden = true
            tokenPriceView.isHidden = false
            tokenLabel.attributedText = .init(
                tokens,
                font: Theme.font.body,
                fontSmall: Theme.font.caption2
            )
            usdPriceLabel.attributedText = .init(
                fiat,
                font: Theme.font.callout,
                fontSmall: Theme.font.caption2,
                foregroundColor: Theme.color.textSecondary
            )
        } else {
            symbolLabel.isHidden = false
            tokenPriceView.isHidden = true
        }
    }
    
    func updateSeparator(with position: CurrencyPickerViewModel.Position) {
        switch position {
        case .single:
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
            separatorTopViewLeadingConstraint.constant = Theme.padding
            separatorTopViewTrailingConstraint.constant = 0
            separatorBottomView.isHidden = true
        case .last:
            separatorTopView.isHidden = false
            separatorTopViewLeadingConstraint.constant = Theme.padding
            separatorTopViewTrailingConstraint.constant = 0
            separatorBottomView.isHidden = false
        default:
            break
        }
    }
}
