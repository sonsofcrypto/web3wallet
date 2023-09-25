// Created by web3d3v on 12/10/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

class CollectionBackgroundView: UIView {
    var topInset = CGFloat(0) {
        didSet { oldValue != topInset ? setNeedsLayout() : () }
    }
    var insetView = UIView()
    var gradientView = ThemeGradientView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureUI()
    }

    func configureUI() {
        insertSubview(insetView, at: 0)
        insertSubview(gradientView, at: 0)
        insetView.backgroundColor = gradientView.colors.first
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        insetView.frame = CGRect(
            zeroOrigin: .init(width: bounds.width, height: topInset)
        )
        gradientView.frame = CGRect(
            origin: .init(x: 0, y: topInset),
            size: .init(width: bounds.width, height: bounds.height - topInset)
        )
    }
}
