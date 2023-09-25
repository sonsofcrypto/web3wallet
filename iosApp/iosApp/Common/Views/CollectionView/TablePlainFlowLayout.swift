// Created by web3d3v on 12/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit


class TablePlainFlowLayout: TableFlowLayout {

    override func layoutAttributesForElements(
        in rect: CGRect
    ) -> [UICollectionViewLayoutAttributes]? {
        var attrs = super.layoutAttributesForElements(in: rect)
        
        let bgAttrs = Set((attrs ?? []).map { $0.indexPath.section }).map {
            layoutAttributesForDecorationView(
                ofKind: SectionBackgroundView.elementKind,
                at: IndexPath(item: 0, section: $0)
            )
        }.compactMap { $0 }
        
        let separators = (attrs ?? []).map {
            layoutAttributesForDecorationView(
                ofKind: SeparatorCellView.elementKind,
                at: $0.indexPath
            )
        }.compactMap { $0 }
        
        attrs?.append(contentsOf: bgAttrs)
        attrs?.append(contentsOf: separators)
        return attrs
    }
        
    override func layoutAttributesForDecorationView(
        ofKind elementKind: String,
        at indexPath: IndexPath
    ) -> UICollectionViewLayoutAttributes? {
        let itemCnt = self.itemsCount[indexPath.section] ?? 0
        
        if elementKind == SectionBackgroundView.elementKind &&
            indexPath.item == 0 &&
            itemCnt > 0,
            let topAttr = layoutAttributesForItem(
                at: IndexPath(item: 0, section: indexPath.section)
            ),
            let bottomAttr = layoutAttributesForItem(
                at: IndexPath(item: itemCnt, section: indexPath.section)
            ) {
            let attr = TableFlowLayoutAttributes(
                forDecorationViewOfKind: SectionBackgroundView.elementKind,
                with:indexPath
            )
            attr.zIndex = -10
            attr.backgroundColor = sectionBackgroundColor
            attr.borderColor = sectionBackgroundBorderColor
            attr.frame = CGRect(
                origin: .init(x: topAttr.frame.minX - 1, y: topAttr.frame.minY),
                size: .init(
                    width: topAttr.bounds.width + separatorHeight * 2,
                    height: bottomAttr.frame.minY - topAttr.frame.minY)
            )
            return attr
        }
        
        if elementKind == SeparatorCellView.elementKind &&
            indexPath.item < (itemCnt - 1),
            let cellAttr = layoutAttributesForItem(at: indexPath) {
                let insets = separatorInsets
                let attr = TableFlowLayoutAttributes(
                    forDecorationViewOfKind: SeparatorCellView.elementKind,
                    with:indexPath
                )
                attr.zIndex = cellAttr.zIndex + 1
                attr.borderColor = separatorColor
                attr.frame = CGRect(
                    x: cellAttr.frame.origin.x + separatorInsets.left,
                    y: cellAttr.frame.maxY + separatorHeight,
                    width: cellAttr.frame.width - insets.left - insets.right,
                    height: separatorHeight
                )
                return attr
        }
        
        return super.layoutAttributesForDecorationView(
            ofKind: elementKind,
            at: indexPath
        )
    }
}
