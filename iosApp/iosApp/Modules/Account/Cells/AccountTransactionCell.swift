// Created by web3d3v on 20/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

class AccountTransactionCell: CollectionViewCell {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        dateLabel.applyStyle(.smallerLabel)
        addressLabel.applyStyle(.smallerLabel)
        addressLabel.textColor = ThemeOG.color.textTertiary
        amountLabel.applyStyle(.subheadGlow)
        layer.cornerRadius = Global.cornerRadius * 2
    }
}

// MARK: - AccountViewModel

extension AccountTransactionCell {

    func update(with viewModel: AccountViewModel.Transaction?) {
        dateLabel.text = viewModel?.date
        amountLabel.text = viewModel?.amount
        addressLabel.text = viewModel?.address
        amountLabel.textColor = (viewModel?.isReceive ?? false)
            ? ThemeOG.color.green
            : ThemeOG.color.red
        amountLabel.layer.shadowColor = amountLabel.textColor.cgColor
    }
}
