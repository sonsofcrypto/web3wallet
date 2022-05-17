// Created by web3d3v on 13/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

final class AMMsCell: CollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.applyStyle(.headlineGlow)
        subTitleLabel.applyStyle(.smallestLabel)
    }
}

extension AMMsCell {

    func update(with viewModel: AMMsViewModel.DApp?) {
        titleLabel.text = viewModel?.title
        subTitleLabel.text = viewModel?.network
        imageView.image = UIImage(named: viewModel?.image  ?? "")
    }
}
