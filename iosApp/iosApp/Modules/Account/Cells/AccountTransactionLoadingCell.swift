// Created by web3d4v on 24/08/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

final class AccountTransactionLoadingCell: CollectionViewCell {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var label: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        label.apply(style: .callout)
        label.textColor = Theme.colour.labelSecondary
        label.numberOfLines = 0
        layer.cornerRadius = Theme.constant.cornerRadiusSmall * 2
        activityIndicator.tintColor = Theme.colour.activityIndicator
    }
    
    override func setSelected(_ selected: Bool) {}
    
    func update(with transaction: AccountViewModel.Transaction) {
        guard let text = transaction.loading else { return }
        label.text = text
        activityIndicator.startAnimating()
    }
}
