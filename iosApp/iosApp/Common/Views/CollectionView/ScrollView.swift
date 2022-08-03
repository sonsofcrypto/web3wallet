// Created by web3d4v on 20/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

class ScrollView: UIScrollView {

    private(set) var overScrollView: UIImageView = .init()

    override func didMoveToSuperview() {
        
        super.didMoveToSuperview()

        guard superview != nil else { return }

        if overScrollView.superview == nil {
            insertSubview(overScrollView, at: 0)
        }

        overScrollView.contentMode = .scaleAspectFit
        overScrollView.addConstraints(
            [
                .layout(
                    anchor: .widthAnchor,
                    constant: .equalTo(constant: Constant.overScrollViewSize.width)
                ),
                .layout(
                    anchor: .heightAnchor,
                    constant: .equalTo(constant: Constant.overScrollViewSize.height)
                )
            ]
        )
    }

    override func layoutSubviews() {
        
        super.layoutSubviews()
        
        overScrollView.center.x = bounds.width / 2
        overScrollView.center.y = max(
            contentSize.height
            + overScrollView.bounds.height.half
            - contentInset.bottom
            + Theme.constant.padding,
            frame.maxY
            + overScrollView.bounds.height.half
            + Theme.constant.padding
        )

    }
}

private extension ScrollView {

    enum Constant {
        
        static let overScrollViewSize = CGSize(length: 100)
    }
}
