// Created by web3d4v on 24/08/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

final class AccountTransactionLoadingCell: CollectionViewCell {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var label: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        label.apply(style: .callout)
        label.textColor = Theme.color.textPrimary
        label.numberOfLines = 0
        layer.cornerRadius = Theme.cornerRadiusSmall * 2
        activityIndicator.color = Theme.color.activityIndicator
    }
    
    override func setSelected(_ selected: Bool) {}
    
    func update(with viewModel: AccountViewModel.TransactionLoading) {
        label.text = viewModel.text
        activityIndicator.startAnimating()
    }
}
