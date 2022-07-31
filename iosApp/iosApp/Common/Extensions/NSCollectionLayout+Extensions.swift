// Created by web3d4v on 15/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit


extension NSCollectionLayoutSection {
    
    convenience init(
        group: NSCollectionLayoutGroup,
        contentInsets: NSDirectionalEdgeInsets? = nil
    ) {
        self.init(group: group)
        if let contentInsets = contentInsets {
            self.contentInsets = contentInsets
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