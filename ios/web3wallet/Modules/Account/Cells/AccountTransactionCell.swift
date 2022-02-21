// Created by web3d3v on 20/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

class AccountTransactionCell: CollectionViewCell {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!

    var cornerStyle: Style = .single {
        didSet { update(for: cornerStyle) }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        dateLabel.applyStyle(.smallerLabel)
        addressLabel.applyStyle(.smallerLabel)
        addressLabel.textColor = Theme.current.textColorTertiary
        amountLabel.applyStyle(.subheadGlow)
    }
}

// MARK: - Style

extension AccountTransactionCell {

    enum Style {
        case top
        case bottom
        case middle
        case single
    }

    func update(for style: AccountTransactionCell.Style) {
        switch style {
        case .top:
            layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        case .bottom:
            layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        case .middle:
            layer.maskedCorners = []
        case .single:
            layer.maskedCorners = [
                .layerMinXMinYCorner,
                .layerMaxXMinYCorner,
                .layerMinXMaxYCorner,
                .layerMaxXMaxYCorner
            ]
        }
    }
}

// MARK: - AccountViewModel

extension AccountTransactionCell {

    func update(with viewModel: AccountViewModel.Transaction?) {
        dateLabel.text = viewModel?.date
        amountLabel.text = viewModel?.amount
        addressLabel.text = viewModel?.address
        amountLabel.textColor = (viewModel?.isReceive ?? false)
            ? Theme.current.green
            : Theme.current.red
        amountLabel.layer.shadowColor = amountLabel.textColor.cgColor
    }
}
