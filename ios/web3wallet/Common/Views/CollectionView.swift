//
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT
//

import UIKit

class CollectionView: UICollectionView {

    private(set) var overScrollView: UIImageView = .init()

    override func didMoveToSuperview() {
        super.didMoveToSuperview()

        guard let _ = superview else {
            return
        }

        if overScrollView.superview == nil {
            addSubview(overScrollView)
        }

        overScrollView.contentMode = .center
        overScrollView.bounds.size = Constant.overScrollViewSize
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        overScrollView.center.x = bounds.width / 2
        overScrollView.center.y = max(
            contentSize.height -
            adjustedContentInset.bottom +
            overScrollView.bounds.height +
            contentInset.bottom
            ,
            frame.maxY
        )

        // print(bounds.origin.y, adjustedContentInset.top, adjustedContentInset.bottom, bounds.height ,contentSize.height)
    }
}

// MARK: - Constant

extension CollectionView {

    enum Constant {
        static let overScrollViewSize = CGSize(length: 200)
    }
}
