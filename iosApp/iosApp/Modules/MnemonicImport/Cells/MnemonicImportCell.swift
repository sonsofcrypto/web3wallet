// Created by web3d3v on 13/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

final class MnemonicImportCell: UICollectionViewCell {

    typealias TextChangeHandler = (String) -> Void

    @IBOutlet weak var textView: UITextView!

    var textChaneHandler: TextChangeHandler?
    var textEditingEndHandler: TextChangeHandler?

    private var viewModel: MnemonicImportViewModel.Mnemonic? = nil

    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        configure()
    }

    func configure() {
        
        layer.cornerRadius = Theme.constant.cornerRadius
        backgroundColor = Theme.colour.labelQuaternary
        
        var attrs: [NSAttributedString.Key: Any] = [
            .font: Theme.font.body,
            .foregroundColor: Theme.colour.labelPrimary
        ]
        attrs[.font] = Theme.font.body

        textView.typingAttributes = attrs
        textView.backgroundColor = .clear
        textView.delegate = self
    }
    
    func textShadow(_ tint: UIColor) -> NSShadow {
        
        let shadow = NSShadow()
        shadow.shadowOffset = .zero
        shadow.shadowBlurRadius = Global.shadowRadius
        shadow.shadowColor = tint
        return shadow
    }

    func update(
        with viewModel: MnemonicImportViewModel.Mnemonic?,
        textChangeHandler: TextChangeHandler? = nil,
        textEditingEndHandler: TextChangeHandler? = nil
    ) -> MnemonicImportCell {
        guard let viewModel = viewModel else {
            return self
        }

        self.viewModel = viewModel
        self.textChaneHandler = textChangeHandler
        self.textEditingEndHandler = textEditingEndHandler

        textView.isEditable = true
        textView.isUserInteractionEnabled = true

        if !textView.isFirstResponder {
            textView.text = viewModel.value
        }

        return self
    }
}

// MARK: - UITextViewDelegate

extension MnemonicImportCell: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textChaneHandler?(textView.text)
            textView.resignFirstResponder()
            return false
        }
        return true
    }

    func textViewDidChange(_ textView: UITextView) {
        textChaneHandler?(textView.text)
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        textEditingEndHandler?(textView.text)
    }
}
