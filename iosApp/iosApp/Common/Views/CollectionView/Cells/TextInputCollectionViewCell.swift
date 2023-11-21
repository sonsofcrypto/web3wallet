// Created by web3d4v on 05/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

final class TextInputCollectionViewCell: ThemeCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textField: TextField!
    
    private var inputHandler: ((String)->Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.adjustsFontSizeToFitWidth = true
        textField.delegate = self
        textField.inputAccessoryView = UIToolbar
            .withDoneButton(self, action: #selector(resignFirstResponder))
            .wrapInInputView()
    }

    override func applyTheme(_ theme: ThemeProtocol) {
        titleLabel.font = Theme.font.body
        titleLabel.textColor = Theme.color.textPrimary
    }

    func update(
        with viewModel: CellViewModel.TextInput?,
        inputHandler: ((String)->Void)? = nil
    ) -> Self {
        titleLabel.text = viewModel?.title
        textField.text = viewModel?.value
        textField.placeholderAttrText = viewModel?.placeholder
        self.inputHandler = inputHandler
        return self
    }
    
    override func resignFirstResponder() -> Bool {
        textField.resignFirstResponder()
    }
}

extension TextInputCollectionViewCell: UITextFieldDelegate {
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        inputHandler?(textField.text ?? "")
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}
