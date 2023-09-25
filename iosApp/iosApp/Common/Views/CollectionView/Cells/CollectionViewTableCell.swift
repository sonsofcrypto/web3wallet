// Created by web3d3v on 12/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

class CollectionViewTableCell: UICollectionViewCell {
    
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        
        if let attr = layoutAttributes as? TableFlowLayoutAttributes {
            layer.maskedCorners = attr.cornerMask
            layer.cornerRadius = 16
            clipsToBounds = true
            
            backgroundView?.layer.maskedCorners = attr.cornerMask
            backgroundView?.layer.cornerRadius = 16
            backgroundView?.clipsToBounds = true            
        }
    }
}
