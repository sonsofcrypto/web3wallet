// Created by web3d3v on 12/04/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

class CollectionViewTextInputCell: CollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textField: UITextField!

    override func configureUI() {
        super.configureUI()
        guard let titleLabel = titleLabel else {
            return
        }
        titleLabel.applyStyle(.bodyGlow)
    }
}

// MARK: - NewMnemonicViewModel.Name

extension CollectionViewTextInputCell {

    func update(with viewModel: NewMnemonicViewModel.Name) -> CollectionViewTextInputCell {
        titleLabel.text = viewModel.title
        textField.text = viewModel.value
        textField.attributedPlaceholder = NSAttributedString(
            string: viewModel.placeHolder,
            attributes: Theme.current.placeholderTextAttributes()
        )
        return self
    }
}
