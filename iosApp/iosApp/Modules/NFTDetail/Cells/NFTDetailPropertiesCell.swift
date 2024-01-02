// Created by web3d3v on 02/01/2024.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

class NFTDetailPropertiesCell: ThemeCell {
    @IBOutlet weak var stack: UIStackView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!

    override func applyTheme(_ theme: ThemeProtocol) {
        super.applyTheme(theme)
        titleLabel.textColor = theme.color.textPrimary
        titleLabel.font = theme.font.headlineBold
        contentView.backgroundColor = theme.color.bgPrimary
        contentView.layer.cornerRadius = theme.cornerRadius
        contentView.layer.borderColor = theme.color.collectionSectionStroke.cgColor
        contentView.layer.borderWidth = 1
    }

    func update(with viewModel: NFTDetailViewModel.InfoGroup?) -> Self {
        guard let viewModel = viewModel else { return self }
        titleLabel.text = viewModel.title
        var attrStr = NSMutableAttributedString()
        for prop in viewModel.items {
            attrStr.append(.init(string: prop.title ?? "", attributes: titleAttrs()))
            if prop.title?.count ?? 0 != 0 {
                attrStr.append(.init(string: " ", attributes: bodyAttrs()))
            }
            attrStr.append(.init(string: prop.body ?? "", attributes: bodyAttrs()))
            attrStr.append(.init(string: "\n", attributes: bodyAttrs()))
        }
        contentLabel.attributedText = attrStr
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
            ).sizeAddingToHeight(Theme.padding)
        }
        return attrs
    }

    private func titleAttrs() -> [NSAttributedString.Key: Any] {
        [
            .foregroundColor: Theme.color.textSecondary,
            .font: Theme.font.subheadline,
            .paragraphStyle: NSParagraphStyle.with(lineSpacing: 6)
        ]
    }

    private func bodyAttrs() -> [NSAttributedString.Key: Any] {
        [
            .foregroundColor: Theme.color.textPrimary,
            .font: Theme.font.subheadlineBold,
            .paragraphStyle: NSParagraphStyle.with(lineSpacing: 6)
        ]
    }
}
