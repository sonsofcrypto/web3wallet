// Created by web3d3v on 12/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

class SeparatorCellView: UICollectionReusableView {
        
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        
        guard let attr = layoutAttributes as? TableFlowLayoutAttributes else {
            backgroundColor = .secondarySystemBackground
            return
        }
        
        backgroundColor = attr.borderColor
    }
    
    static var elementKind: String {
        "\(SeparatorCellView.self)"
    }
}
