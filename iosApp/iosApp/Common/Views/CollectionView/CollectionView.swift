// Created by web3d3v on 20/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

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

        overScrollView.contentMode = .scaleAspectFit
        overScrollView.bounds.size = Constant.overScrollViewSize
        overScrollView.backgroundColor = .yellow
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        overScrollView.center.x = bounds.width / 2
        let top = contentSize.height + overScrollView.bounds.height.half - contentInset.bottom
        let btm = frame.maxY
            - adjustedContentInset.top
            - adjustedContentInset.bottom
            - overScrollView.bounds.height.half
        overScrollView.center.y = max(top, btm)
    }
}

// MARK: - Constant

extension CollectionView {

    enum Constant {
        static let overScrollViewSize = CGSize(length: 150)
    }
}
