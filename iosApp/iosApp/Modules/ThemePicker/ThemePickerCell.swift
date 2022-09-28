// Created by web3d3v on 08/08/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

final class ThemePickerCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!

    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.layer.cornerRadius = 20
        imageView.layer.maskedCorners = .all
        imageView.bounds.size = CGSize(
            width: bounds.width * 0.8,
            height: bounds.height * 0.8
        )
        imageView.center = bounds.midXY
    }
}

