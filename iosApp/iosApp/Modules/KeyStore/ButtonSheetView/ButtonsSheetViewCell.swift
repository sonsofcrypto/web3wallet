// Created by web3d3v on 13/04/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

class ButtonsSheetViewCell: CollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.applyStyle(.bodyGlow)
    }
}

// MARK: - ButtonsSheetViewModel

extension ButtonsSheetViewCell {

    func update(with viewModel: ButtonSheetViewModel.Button?) -> ButtonsSheetViewCell {
        titleLabel.text = viewModel?.title ?? ""
        return self
    }
}
