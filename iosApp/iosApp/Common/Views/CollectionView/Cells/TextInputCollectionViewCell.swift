// Created by web3d4v on 05/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

final class TextInputCollectionViewCell: CollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textField: TextField!

    private var textChangeHandler: ((String)->Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        
        titleLabel.font = Theme.font.body
        titleLabel.textColor = Theme.color.textPrimary
        titleLabel.adjustsFontSizeToFitWidth = true
        
        textField.delegate = self
        textField.addDoneInputAccessoryView(
            with: .targetAction(.init(target: self, selector: #selector(resignFirstResponder)))
        )
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
        with viewModel: TextInputCollectionViewModel,
        textChangeHandler: ((String)->Void)? = nil
    ) -> Self {
        
        titleLabel.text = viewModel.title
        textField.text = viewModel.value
        textField.placeholderAttrText = viewModel.placeholder
        self.textChangeHandler = textChangeHandler
        return self
    }
}
