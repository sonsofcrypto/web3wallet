// Created by web3d3v on 02/01/2024.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

class NFTDetailImageCell: ThemeCell {
    @IBOutlet weak var stack: UIStackView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label: UILabel!

    override func applyTheme(_ theme: ThemeProtocol) {
        super.applyTheme(theme)
        label.textColor = theme.color.textPrimary
        label.font = theme.font.headlineBold
        contentView.backgroundColor = theme.color.bgPrimary
        contentView.layer.cornerRadius = theme.cornerRadius
        contentView.layer.borderColor = theme.color.collectionSectionStroke.cgColor
        contentView.layer.borderWidth = 1
    }

    func update(with viewModel: NFTDetailViewModel?) -> Self {
        guard let viewModel = viewModel else { return self }
        imageView.setImage(
            url: viewModel.imageURL,
            fallBackUrl: viewModel.fallBackImageURL,
            fallBackText: viewModel.fallBackTest
        )
        label.text = Localized("nft.detail.section.id", viewModel.tokenID)
        return self
    }

    override func preferredLayoutAttributesFitting(
        _ layoutAttributes: UICollectionViewLayoutAttributes
    ) -> UICollectionViewLayoutAttributes {
        var attrs = super.preferredLayoutAttributesFitting(layoutAttributes)
        if let cv = collectionView() {
            attrs.size = stack.systemLayoutSizeFitting(
                .init(
                    width: cv.bounds.width - cv.contentInset.horizontal(),
                    height: 0
                ),
                withHorizontalFittingPriority: .defaultHigh,
                verticalFittingPriority: .defaultLow
            )
        }
        return attrs
    }
}
