// Created by web3d4v on 05/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

struct TextInputCollectionViewModel {
    let title: String
    let value: String
    let placeholder: String
}

final class TextInputCollectionViewCell: CollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textField: TextField!

    private var textChangeHandler: ((String)->Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        
        titleLabel.font = Theme.font.body
        titleLabel.textColor = Theme.colour.labelPrimary
        
        textField.delegate = self
    }
    
    override func resignFirstResponder() -> Bool {
        textField.resignFirstResponder()
    }
    
    override func setSelected(_ selected: Bool) {}
}

extension TextInputCollectionViewCell: UITextFieldDelegate {
    
    func textFieldDidChangeSelection(_ textField: UITextField) {

        textChangeHandler?(textField.text ?? "")
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}

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
    }

    func update(
        with viewModel: MnemonicImportViewModel.Name,
        textChangeHandler: ((String)->Void)? = nil
    ) -> Self {
        
        update(
            title: viewModel.title,
            value: viewModel.value,
            placeholder: viewModel.placeholder,
            textChangeHandler: textChangeHandler
        )
    }
}

private extension TextInputCollectionViewCell {

    func update(
        title: String,
        value: String,
        placeholder: String,
        textChangeHandler: ((String)->Void)? = nil
    ) -> Self {
        
        titleLabel.text = title
        textField.text = value
        textField.placeholderAttrText = placeholder
        self.textChangeHandler = textChangeHandler
        return self
    }
}
