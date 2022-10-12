// Created by web3d3v on 20/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

class CollectionView: UICollectionView {

    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        configureUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureUI()
    }

    private(set) var overScrollView: UIImageView = .init()

    override func didMoveToSuperview() {
        super.didMoveToSuperview()

        guard let _ = superview else { return }

        if overScrollView.superview == nil {
            addSubview(overScrollView)
        }

        overScrollView.contentMode = .scaleAspectFit
        overScrollView.bounds.size = Constant.overScrollViewSize
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        overScrollView.center.x = bounds.width / 2
        overScrollView.center.y = max(
            contentSize.height
                - adjustedContentInset.bottom
                + overScrollView.bounds.height.half,
            frame.maxY
                - adjustedContentInset.top
                - adjustedContentInset.bottom
                + overScrollView.bounds.height.half
        )
        (backgroundView as? BackgroundView)?.topInset = adjustedContentInset.top
        (backgroundView as? DashboardBackgroundView)?.layoutForCollectionView(self)

    }

    func configureUI() {
        backgroundView = BackgroundView()
    }
}

extension CollectionView {

    enum Constant {
        static let overScrollViewSize = CGSize(length: 150)
    }
}
