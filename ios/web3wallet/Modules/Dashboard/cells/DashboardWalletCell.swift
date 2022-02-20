// Created by web3d3v on 19/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

class DashboardWalletCell: CollectionViewCell {

    @IBOutlet weak var contentStack: UIStackView!
    @IBOutlet weak var topContentStack: UIStackView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var fiatBalanceLabel: UILabel!
    @IBOutlet weak var pctChangeLabel: UILabel!
    @IBOutlet weak var charView: UIView!
    @IBOutlet weak var cryptoBalanceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = Global.cornerRadius * 2
        contentStack.setCustomSpacing(13, after: topContentStack)
        currencyLabel.applyStyle(.callout)
        pctChangeLabel.applyStyle(.callout)
        [fiatBalanceLabel, pctChangeLabel].forEach { $0.applyStyle(.smallLabel) }
        fiatBalanceLabel.textColor = Theme.current.textColorSecondary
        cryptoBalanceLabel.applyStyle(.callout)
    }
}

// MARK: - DashboardViewModel

extension DashboardWalletCell {

    func update(with viewModel: DashboardViewModel.Wallet) {
        imageView.image = UIImage(named: viewModel.imageName)
        currencyLabel.text = viewModel.name
        fiatBalanceLabel.text = viewModel.fiatBalance
        pctChangeLabel.text = viewModel.pctChange
        pctChangeLabel.textColor = viewModel.priceUp
            ? Theme.current.green
            : Theme.current.red
        pctChangeLabel.layer.shadowColor = pctChangeLabel.textColor.cgColor
//        charView
        cryptoBalanceLabel.text = viewModel.cryptoBalance
    }
}
