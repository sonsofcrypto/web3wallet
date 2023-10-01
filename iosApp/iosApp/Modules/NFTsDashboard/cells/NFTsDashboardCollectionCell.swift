// Created by web3d3v on 30/09/2023.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

class NFTsDashboardCollectionCell: ThemeCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label: UILabel!

    func update(
        with viewModel: NFTsDashboardViewModel.Loaded.Collection?
    ) -> Self {
        label.text = viewModel?.title
        imageView.setImage(
            url: viewModel?.coverImage,
            fallBackText: Localized("ipfs.image.unavailable")
        )
        return self
    }

    override func applyTheme(_ theme: ThemeProtocol) {
        label.textColor = theme.color.textPrimary
        label.font = theme.font.footnote
        layer.cornerRadius = theme.cornerRadius
        backgroundColor = theme.color.bgPrimary
    }
}
