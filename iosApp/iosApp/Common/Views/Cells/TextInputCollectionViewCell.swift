// Created by web3d4v on 05/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

final class TextInputCollectionViewCell: CollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textField: UITextField!

    var textChangeHandler: ((String)->Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        
        titleLabel.font = Theme.font.body
        titleLabel.textColor = Theme.colour.labelPrimary
        
        textField.delegate = self
        textField.rightViewMode = .whileEditing
    }
    
    override func resignFirstResponder() -> Bool {
        textField.resignFirstResponder()
    }
}

extension TextInputCollectionViewCell: UITextFieldDelegate {

    func textFieldDidEndEditing(_ textField: UITextField) {
        textChangeHandler?(textField.text ?? "")
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        textChangeHandler?(textField.text ?? "")
        return false
    }
}

// MARK: - Update view viewModel

extension TextInputCollectionViewCell {

    func update(
        with viewModel: MnemonicNewViewModel.Name,
        textChangeHandler: ((String)->Void)? = nil
    ) -> Self {
        update(
            title: viewModel.title,
            value: viewModel.value,
            placeholder: viewModel.placeholder,
            textChangeHandler: textChangeHandler
        )
        return self
    }

    func update(
        with viewModel: MnemonicUpdateViewModel.Name,
        textChangeHandler: ((String)->Void)? = nil
    ) -> Self {
        update(
            title: viewModel.title,
            value: viewModel.value,
            placeholder: viewModel.placeholder,
            textChangeHandler: textChangeHandler
        )
        return self
    }
}

// MARK: - Utilities

private extension TextInputCollectionViewCell {

    func update(
        title: String,
        value: String,
        placeholder: String,
        textChangeHandler: ((String)->Void)? = nil
    ) -> Self {
        titleLabel.text = title
        textField.text = value
        (textField as? TextField)?.placeholderAttrText = placeholder
        self.textChangeHandler = textChangeHandler
        return self
    }

}