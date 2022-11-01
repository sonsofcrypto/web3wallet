// Created by web3d3v on 07/08/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

final class DashboardTableWalletCell: CollectionViewCell {
    
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
        pctChangeLabel.apply(style: .callout, colour: Theme.colour.candleRed)
        chevronView.tintColor = Theme.colour.labelSecondary
    }
    
    override func setSelected(_ selected: Bool) {}
}

// MARK: - ViewModel

extension DashboardTableWalletCell {
    
    func update(
        with viewModel: DashboardViewModel.Wallet?,
        showBottomSeparator: Bool = true
    ) -> Self {
        guard let viewModel = viewModel else { return self }
        currencyImageView.image = viewModel.imageName.assetImage
        fiatPriceLabel.attributedText = .init(
            viewModel.fiatPrice.toOutput(style: Formatters.StyleCustom(maxLength: 9.uint32)),
            font: Theme.font.callout,
            fontSmall: Theme.font.caption2,
            foregroundColor: Theme.colour.labelSecondary
        )
        currencyNameLabel.text = viewModel.name
        pctChangeLabel.text = viewModel.pctChange
        if viewModel.priceUp {
            pctChangeLabel.apply(style: .callout, colour: Theme.colour.candleGreen)
        } else {
            pctChangeLabel.apply(style: .callout, colour: Theme.colour.candleRed)
        }
        cryptoBalanceLabel.attributedText = .init(
            viewModel.cryptoBalance.toOutput(style: Formatters.StyleCustom(maxLength: 10.uint32)),
            font: Theme.font.body,
            fontSmall: Theme.font.footnote
        )
        fiatBalanceLabel.attributedText = .init(
            viewModel.fiatBalance.toOutput(style: Formatters.StyleCustom(maxLength: 10.uint32)),
            font: Theme.font.callout,
            fontSmall: Theme.font.caption2,
            foregroundColor: Theme.colour.labelSecondary
        )
        bottomSeparatorView.isHidden = !showBottomSeparator
        return self
    }
}
