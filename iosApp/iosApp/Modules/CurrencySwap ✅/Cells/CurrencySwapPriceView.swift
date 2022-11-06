// Created by web3d4v on 17/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import web3walletcore

final class CurrencySwapPriceView: UIView {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        nameLabel.apply(style: .footnote)
        nameLabel.text = Localized("currencySwap.cell.price")
    }
}

extension CurrencySwapPriceView {
    
    func update(with viewModel: CurrencySwapPriceViewModel) {
        valueLabel.attributedText = .init(
            viewModel.value,
            font: Theme.font.footnote,
            fontSmall: Theme.font.extraSmall,
            foregroundColor: Theme.colour.labelPrimary
        )
    }
}
