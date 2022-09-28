// Created by web3d4v on 24/08/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

final class AccountTransactionEmptyCell: CollectionViewCell {

    @IBOutlet weak var label: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        label.apply(style: .callout)
        label.textColor = Theme.colour.labelSecondary
        layer.cornerRadius = Theme.constant.cornerRadiusSmall * 2
    }
    
    func update(with transaction: AccountViewModel.Transaction) {
        guard let text = transaction.empty else { return }
        label.text = text
    }
    
    override func setSelected(_ selected: Bool) {}

}
