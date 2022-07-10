// Created by web3d4v on 05/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

final class MnemonicTextInputCollectionViewCell: CollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textField: TextField!

    var textChangeHandler: ((String)->Void)?

    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        titleLabel.font = Theme.font.body
        titleLabel.textColor = Theme.colour.labelPrimary
        
        textField.delegate = self
        textField.rightView = makeClearButton()
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
        with viewModel: MnemonicViewModel.Name,
        textChangeHandler: ((String)->Void)? = nil
    ) -> Self {
        
        titleLabel.text = viewModel.title
        textField.text = viewModel.value
        textField.attributedPlaceholder = NSAttributedString(
            string: viewModel.placeholder,
            attributes: [
                NSAttributedString.Key.font: Theme.font.body,
                NSAttributedString.Key.foregroundColor: Theme.colour.textFieldPlaceholderColour
            ]
        )
        self.textChangeHandler = textChangeHandler
        return self
    }
}


private extension MnemonicTextInputCollectionViewCell {
    
    func makeClearButton() -> UIButton {
        
        let button = UIButton(type: .system)
        button.setImage(
            .init(systemName: "xmark.circle.fill"),
            for: .normal
        )
        button.tintColor = Theme.colour.labelSecondary
        button.addTarget(self, action: #selector(clearTapped), for: .touchUpInside)
        return button
    }
    
    @objc func clearTapped() {
        
        textField.text = nil
    }
}
