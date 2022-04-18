// Created by web3d3v on 20/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

class AccountMarketInfoCell: CollectionViewCell {

    @IBOutlet weak var marketCapTitleLabel: UILabel!
    @IBOutlet weak var priceTitleLabel: UILabel!
    @IBOutlet weak var volumeTitleLabel: UILabel!
    @IBOutlet weak var marketCapValueLabel: UILabel!
    @IBOutlet weak var priceValueLabel: UILabel!
    @IBOutlet weak var volumeValueLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        [marketCapTitleLabel, priceTitleLabel, volumeTitleLabel].forEach {
            $0?.applyStyle(.smallLabel)
            $0?.textColor = Theme.color.textSecondary
        }
        [marketCapValueLabel, priceValueLabel, volumeValueLabel].forEach {
            $0?.applyStyle(.subheadGlow)
        }

        layer.cornerRadius = Global.cornerRadius * 2
    }
}

// MARK: - AccountViewModel

extension AccountMarketInfoCell {

    func update(with viewModel: AccountViewModel.MarketInfo?) {
        marketCapTitleLabel.text = Localized("account.marketInfo.marketCap")
        priceTitleLabel.text = Localized("account.marketInfo.price")
        volumeTitleLabel.text = Localized("account.marketInfo.volume")
        marketCapValueLabel.text = viewModel?.marketCap
        priceValueLabel.text = viewModel?.price
        volumeValueLabel.text = viewModel?.volume
    }
}
