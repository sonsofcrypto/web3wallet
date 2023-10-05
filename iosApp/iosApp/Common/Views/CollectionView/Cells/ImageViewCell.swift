// Created by web3d3v on 12/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

class ImageViewCell: ThemeCell {
    @IBOutlet weak var imageView: UIImageView!
    
    override func applyTheme(_ theme: ThemeProtocol) {
        layer.cornerRadius = theme.cornerRadius
        backgroundColor = theme.color.bgPrimary
    }
}

extension ImageViewCell {
    
    func update(with viewModel: NFTsCollectionViewModel.NFT?) -> Self {
        imageView.setImage(
            url: viewModel?.previewImage ?? viewModel?.image,
            fallBackUrl: viewModel?.image,
            fallBackText: viewModel?.fallbackText
        )
        return self
    }
    
}
