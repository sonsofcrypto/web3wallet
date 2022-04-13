// Created by web3d3v on 13/04/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

class TouchPassThroughCollectionView: UICollectionView {

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if point.y >= 0 {
            return super.hitTest(point, with: event)
        }
        return nil
    }
}
