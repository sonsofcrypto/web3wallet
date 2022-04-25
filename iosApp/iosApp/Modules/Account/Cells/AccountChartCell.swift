// Created by web3d3v on 20/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

class AccountChartCell: CollectionViewCell {

    @IBOutlet weak var candlesView: CandlesView!

    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = Global.cornerRadius * 2
    }
}

// MARK: - AccountViewModel

extension AccountChartCell {

    func update(with viewModel: CandlesViewModel?) {
        guard let viewModel = viewModel else {
            return
        }

        candlesView.update(viewModel)
    }
}
