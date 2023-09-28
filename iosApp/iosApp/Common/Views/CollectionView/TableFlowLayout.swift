// Created by web3d3v on 12/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

class TableFlowLayout: UICollectionViewFlowLayout {
    var separatorInsets: UIEdgeInsets = .with(left: 16)
    var separatorColor: UIColor = .secondarySystemBackground
    var sectionBackgroundColor: UIColor = .systemBackground
    var sectionBackgroundBorderColor: UIColor = .secondarySystemBackground
    
    private var isRegistered: Bool = false
    private var prevBoundsWidth: CGFloat = 0
    private var sectionsCount: Int = 0
    private(set) var itemsCount: [Int: Int] = [:]
    private(set) var separatorHeight: CGFloat = 0.5
    
    override func prepare() {
        super.prepare()
        
        guard !isRegistered else { return }
        isRegistered = true
        
        register(
            SectionBackgroundView.self,
            forDecorationViewOfKind:"\(SectionBackgroundView.self)"
        )
        register(
            SeparatorCellView.self,
            forDecorationViewOfKind:"\(SeparatorCellView.self)"
        )
        
        sectionsCount = collectionView?.numberOfSections ?? 0
        if sectionsCount != 0 {
            (0..<sectionsCount).forEach {
                let cnt = collectionView?.numberOfItems(inSection: $0) ?? 0
                itemsCount[$0] = cnt
            }
        }
    }
    
    override func shouldInvalidateLayout(
        forBoundsChange newBounds: CGRect
    ) -> Bool {
        if newBounds.width != prevBoundsWidth {
            prevBoundsWidth = newBounds.width
            // NOTE: Force invilidating here manually as there seems ot be bug
            // where layout is not invilidated dusing device rotation despite
            // returning true
            invalidateLayout()
            return true
        }
        return super.shouldInvalidateLayout(forBoundsChange: newBounds)
    }

    override class var layoutAttributesClass: AnyClass {
        TableFlowLayoutAttributes.self
    }
}

// MARK: - TableFlowLayoutAttributes

class TableFlowLayoutAttributes: UICollectionViewLayoutAttributes {
    var cornerMask: CACornerMask = []
    var backgroundColor: UIColor? = nil
    var borderColor: UIColor? = nil
    
    override func copy(with zone: NSZone? = nil) -> Any {
        let copy = super.copy(with: zone) as! TableFlowLayoutAttributes
        copy.cornerMask = cornerMask
        copy.backgroundColor = backgroundColor
        copy.borderColor = borderColor
        return copy
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        if cornerMask != (object as? TableFlowLayoutAttributes)?.cornerMask {
            return false
        }
        if backgroundColor != (object as? TableFlowLayoutAttributes)?.backgroundColor {
            return false
        }
        if borderColor != (object as? TableFlowLayoutAttributes)?.borderColor {
            return false
        }
        return super.isEqual(object)
    }
}
