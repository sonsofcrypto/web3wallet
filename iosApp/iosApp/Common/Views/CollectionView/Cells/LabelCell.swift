// Created by web3d3v on 12/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT


import UIKit
import web3walletcore

class LabelCell: CollectionViewTableCell {
    @IBOutlet weak var label: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        applyTheme(Theme)
    }

    func update(with viewModel: CellViewModel?) -> Self {
        guard let vm = viewModel as? CellViewModel.Label else {
            return self
        }
        label.text = vm.text
        return self
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        applyTheme(Theme)
    }

    func applyTheme(_ theme: ThemeProtocol) {
        label.textColor = theme.color.textPrimary
        label.font = theme.font.callout
    }
}
