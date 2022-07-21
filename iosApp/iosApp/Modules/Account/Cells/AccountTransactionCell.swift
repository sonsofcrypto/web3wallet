// Created by web3d3v on 20/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

final class AccountTransactionCell: CollectionViewCell {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!

    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        dateLabel.apply(style: .callout)
        addressLabel.apply(style: .callout)
        addressLabel.textColor = Theme.colour.labelSecondary
        amountLabel.apply(style: .subheadline)
        layer.cornerRadius = Theme.constant.cornerRadiusSmall * 2
    }
}

extension AccountTransactionCell {

    func update(with viewModel: AccountViewModel.Transaction?) {
        
        dateLabel.text = viewModel?.date
        amountLabel.text = viewModel?.amount
        addressLabel.text = viewModel?.address
        amountLabel.textColor = (viewModel?.isReceive ?? false)
            ? Theme.colour.priceUp
            : Theme.colour.priceDown
        //amountLabel.layer.shadowColor = amountLabel.textColor.cgColor
    }
}
