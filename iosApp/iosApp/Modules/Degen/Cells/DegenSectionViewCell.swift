// Created by web3d3v on 20/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

final class DegenSectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        label.apply(style: .body, weight: .bold)
    }
}

extension DegenSectionViewCell {

    func update(with viewModel: DegenViewModel.SectionHeader) {
        label.text = viewModel.title
        label.textColor = viewModel.isEnabled ?
        Theme.color.textPrimary :
        Theme.color.textSecondary
    }
}
