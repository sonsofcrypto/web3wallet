// Created by web3d3v on 13/04/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

final class ButtonCell: UICollectionViewCell {
    private lazy var button: Button = {
        let button = Button(frame: bounds)
        button.isUserInteractionEnabled = false
        addSubview(button)
        return button
    }()

    override func layoutSubviews() {
        super.layoutSubviews()
        button.frame = bounds
    }
}

extension ButtonCell {

    func update(with viewModel: ButtonViewModel) -> Self {
        button.update(with: viewModel)
        return self
    }
}
