// Created by web3d3v on 07/08/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

class DashboardTableWalletCell: CollectionViewCell {
    @IBOutlet weak var currencyImageView: UIImageView!
    @IBOutlet weak var currencyNameLabel: UILabel!
    @IBOutlet weak var fiatPriceLabel: UILabel!
    @IBOutlet weak var pctChangeLabel: UILabel!
    @IBOutlet weak var cryptoBalanceLabel: UILabel!
    @IBOutlet weak var fiatBalanceLabel: UILabel!
    @IBOutlet weak var chevronView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        currencyImageView.layer.cornerRadius = currencyImageView.bounds.width.half
        currencyNameLabel.apply(style: .body)
        fiatPriceLabel.apply(style: .callout, colour: Theme.colour.labelSecondary)
        pctChangeLabel.apply(style: .callout, colour: Theme.colour.candleRed)
        cryptoBalanceLabel.apply(style: .body)
        fiatBalanceLabel.apply(style: .callout, colour: Theme.colour.labelSecondary)
        chevronView.tintColor = Theme.colour.labelSecondary
    }
}

// MARK: - ViewModel

extension DashboardTableWalletCell {
    
    func update(with viewModel: DashboardViewModel.Wallet?) -> Self {
        currencyImageView.image = UIImage(data: viewModel?.imageName ?? Data())
        fiatPriceLabel.text = viewModel?.fiatPrice
        currencyNameLabel.text = viewModel?.name
        pctChangeLabel.text = viewModel?.pctChange
        cryptoBalanceLabel.text = viewModel?.cryptoBalance
        fiatBalanceLabel.text = viewModel?.fiatBalance
        bottomSeparatorView.isHidden = false
        return self
    }
}
