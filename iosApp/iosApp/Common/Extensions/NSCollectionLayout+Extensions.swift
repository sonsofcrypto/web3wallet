// Created by web3d4v on 15/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

extension NSCollectionLayoutGroup {

    static func horizontal(
        _ size: NSCollectionLayoutSize,
        items: [NSCollectionLayoutItem],
        spacing: NSCollectionLayoutSpacing? = nil
    ) -> NSCollectionLayoutGroup {
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: size,
            subitems: items
        )
        if let spacing = spacing {
            group.interItemSpacing = spacing
        }
        return group
    }
}

extension NSCollectionLayoutSection {
    
    convenience init(
        group: NSCollectionLayoutGroup,
        insets: NSDirectionalEdgeInsets? = nil
    ) {
        self.init(group: group)
        if let contentInsets = insets {
            self.contentInsets = contentInsets
        }
    }

    static func empty() -> NSCollectionLayoutSection {
        .init(group: .horizontal(.estimated(0, height: 0), items: []))
    }
}

extension NSDirectionalEdgeInsets {

    static var padding: Self {
        .init(
            top: Theme.padding,
            leading: Theme.padding,
            bottom: Theme.padding,
            trailing: Theme.padding
        )
    }

    static var paddingHalf: Self {
        .init(
            top: Theme.paddingHalf,
            leading: Theme.paddingHalf,
            bottom: Theme.paddingHalf,
            trailing: Theme.paddingHalf
        )
    }

    static func padding(
        top: CGFloat = Theme.padding,
        leading: CGFloat = Theme.padding,
        bottom: CGFloat = Theme.padding,
        trailing: CGFloat = Theme.padding
    ) -> NSDirectionalEdgeInsets {
        .init(
            top: top,
            leading: leading,
            bottom: bottom,
            trailing: trailing
        )
    }

    static func insets(h: CGFloat = 0, v: CGFloat = 0) -> Self {
        .init(top: v, leading: h, bottom: v, trailing: h)
    }
}

extension NSCollectionLayoutItem {

    convenience init(
        _ size: NSCollectionLayoutSize,
        insets: NSDirectionalEdgeInsets? = nil
    ) {
        self.init(layoutSize: size)
        if let insets = insets {
            contentInsets = insets
        }
    }
}

extension NSCollectionLayoutBoundarySupplementaryItem {

    convenience init(
        layoutSize: NSCollectionLayoutSize,
        elementKind: String,
        alignment: NSRectAlignment,
        leading: CGFloat = 0,
        trailing: CGFloat = 0
    ) {
        self.init(layoutSize: layoutSize, elementKind: elementKind, alignment: alignment)
        contentInsets = .init(top: 0, leading: leading, bottom: 0, trailing: trailing)
    }

}

extension NSCollectionLayoutSize {

    static func fractional(_ fractional: CGFloat = 1) -> Self {
        .init(
            widthDimension: .fractionalWidth(fractional),
            heightDimension: .fractionalHeight(fractional)
        )
    }

    static func fractional(
        _ width: CGFloat = 1,
        estimatedH: CGFloat = 100
    ) -> Self {
        .init(
            widthDimension: .fractionalWidth(width),
            heightDimension: .estimated(estimatedH)
        )
    }

    static func fractional(
        _ width: CGFloat = 1,
        absoluteH: CGFloat = 100
    ) -> Self {
        .init(
            widthDimension: .fractionalWidth(width),
            heightDimension: .absolute(absoluteH)
        )
    }

    static func estimated(
        _ width: CGFloat = 100,
        height: CGFloat = 100
    ) -> Self {
        .init(
            widthDimension: .estimated(width),
            heightDimension: .estimated(height)
        )
    }

    static func absolute(_ width: CGFloat = 100, height: CGFloat = 100) -> Self {
        .init(
            widthDimension: .absolute(width),
            heightDimension: .absolute(height)
        )
    }

    static func absolute(
        _ width: CGFloat = 100,
        estimatedH: CGFloat = 100
    ) -> Self {
        .init(
            widthDimension: .absolute(width),
            heightDimension: .estimated(estimatedH)
        )
    }
}