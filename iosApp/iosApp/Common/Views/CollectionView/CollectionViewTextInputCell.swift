// Created by web3d3v on 12/04/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

class CollectionViewTextInputCell: CollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textField: UITextField!

    var textChangeHandler: ((String)->Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.applyStyle(.bodyGlow)
        textField.delegate = self
    }
}

// MARK: - UITextFieldDelegate

extension CollectionViewTextInputCell: UITextFieldDelegate {

    func textFieldDidEndEditing(_ textField: UITextField) {
        textChangeHandler?(textField.text ?? "")
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        textChangeHandler?(textField.text ?? "")
        return false
    }
}

// MARK: - MnemonicViewModel.Name

extension CollectionViewTextInputCell {

    func update(
        with viewModel: MnemonicViewModel.Name,
        textChangeHandler: ((String)->Void)? = nil
    ) -> CollectionViewTextInputCell {
        titleLabel.text = viewModel.title
        textField.text = viewModel.value
        (textField as? TextField)?.placeholderAttrText = viewModel.placeholder
        self.textChangeHandler = textChangeHandler
        return self
    }
}
