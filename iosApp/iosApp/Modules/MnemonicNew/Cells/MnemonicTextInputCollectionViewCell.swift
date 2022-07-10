// Created by web3d4v on 05/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

final class MnemonicTextInputCollectionViewCell: CollectionViewCell {

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

extension MnemonicTextInputCollectionViewCell: UITextFieldDelegate {

    func textFieldDidEndEditing(_ textField: UITextField) {
        textChangeHandler?(textField.text ?? "")
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        textChangeHandler?(textField.text ?? "")
        return false
    }
}

extension MnemonicTextInputCollectionViewCell {

    func update(
        with viewModel: MnemonicNewViewModel.Name,
        textChangeHandler: ((String)->Void)? = nil
    ) -> Self {
        titleLabel.text = viewModel.title
        textField.text = viewModel.value
        (textField as? TextField)?.placeholderAttrText = viewModel.placeholder
        self.textChangeHandler = textChangeHandler
        return self
    }
}
