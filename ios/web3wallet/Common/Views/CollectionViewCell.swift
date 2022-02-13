// Created by web3d3v on 13/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

class CollectionViewCell: UICollectionViewCell {

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureUI()
    }

    private func configureUI() {
        backgroundColor = Theme.current.background
        layer.cornerRadius = Global.cornerRadius
        layer.borderWidth = 1
        layer.shadowColor = Theme.current.tintPrimary.cgColor
        layer.shadowRadius = Global.shadowRadius
        layer.shadowOffset = .zero
    }
}
