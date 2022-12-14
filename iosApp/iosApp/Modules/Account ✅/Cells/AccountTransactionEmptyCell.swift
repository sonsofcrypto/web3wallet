// Created by web3d4v on 24/08/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

final class AccountTransactionEmptyCell: CollectionViewCell {

    @IBOutlet weak var label: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        label.apply(style: .callout)
        label.textColor = Theme.color.textSecondary
        layer.cornerRadius = Theme.cornerRadiusSmall * 2
    }
    
    func update(with viewModel: AccountViewModel.TransactionEmpty) {
        label.text = viewModel.text
    }
    
    override func setSelected(_ selected: Bool) {}

}
