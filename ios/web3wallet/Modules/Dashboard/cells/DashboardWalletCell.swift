// Created by web3d3v on 19/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

class DashboardWalletCell: CollectionViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = Global.cornerRadius * 2
    }
}

// MARK: - DashboardViewModel

extension DashboardWalletCell {

    func update(with viewModel: DashboardViewModel.Wallet) {

    }
}