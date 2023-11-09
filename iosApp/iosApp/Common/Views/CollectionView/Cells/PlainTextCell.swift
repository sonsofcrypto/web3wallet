// Created by web3d3v on 09/11/2023.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

class PlainTextCell: UICollectionViewCell {

    let label = UILabel(Theme.font.body, color: Theme.color.tabBarTint)

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }

    func update(with text: String?, color: UIColor? = nil) -> Self {
        label.text = text
        if let color = color {
            label.textColor = color
        }
        return self
    }

    private func configure() {
        label.frame = bounds
        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView.addSubview(label)
    }
}
