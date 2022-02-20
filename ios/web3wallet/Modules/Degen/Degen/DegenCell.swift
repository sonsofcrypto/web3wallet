// Created by web3d3v on 13/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

class DegenCell: CollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.applyStyle(.callout)
        subTitleLabel.applyStyle(.subhead)
    }
}

// MARK: - Extension

extension DegenCell {

    func update(with viewModel: DegenViewModel.Item?) {
        titleLabel.text = viewModel?.title
        subTitleLabel.text = viewModel?.subtitle
    }
}
