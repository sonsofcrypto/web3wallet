// Created by web3d3v on 13/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

class SwapInputView: UIView {

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor.bgGradientTopSecondary
        layer.cornerRadius = Global.cornerRadius
        layer.masksToBounds = true
    }
}

// MARK: - SwapViewModel

extension SwapInputView {

    func update(with viewModel: SwapViewModel.Input) {

    }
}