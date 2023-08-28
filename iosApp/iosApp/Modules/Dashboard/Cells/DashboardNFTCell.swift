// Created by web3d3v on 19/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

final class DashboardNFTCell: CollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = Theme.cornerRadiusSmall * 2
        clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        layer.transform = CATransform3DIdentity
        layer.removeAllAnimations()
    }
}

extension DashboardNFTCell {

    @discardableResult
    func update(with viewModel: DashboardViewModel.SectionItemsNFT?) -> Self {
        guard let viewModel = viewModel else { return self }
        imageView.load(url: viewModel.image)
        return self
    }
}
