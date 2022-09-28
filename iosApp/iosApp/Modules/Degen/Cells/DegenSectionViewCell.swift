// Created by web3d3v on 20/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

final class DegenSectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        label.apply(style: .body, weight: .bold)
    }
}

extension DegenSectionViewCell {

    func update(with viewModel: DegenViewModel.Header) {
        label.text = viewModel.title
        label.textColor = viewModel.isEnabled ?
        Theme.colour.labelPrimary :
        Theme.colour.labelSecondary
    }
}
