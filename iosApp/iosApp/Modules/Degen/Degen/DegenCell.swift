// Created by web3d3v on 13/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

final class DegenCell: CollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        titleLabel.apply(style: .body, weight: .bold)
        subTitleLabel.apply(style: .subheadline, weight: .bold)
    }
}

extension DegenCell {

    func update(with viewModel: DegenViewModel.Item?) {
        
        titleLabel.text = viewModel?.title
        subTitleLabel.text = viewModel?.subtitle
    }
}
