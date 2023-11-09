// Created by web3d3v on 13/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

final class MnemonicImportCell: ThemeCell {
    typealias InputHandler = (_ mnemonic: String, _ cursorLocation: Int) -> Void

    @IBOutlet weak var textView: UITextView!

    private var viewModel: MnemonicInputViewModel?
    private var handler: InputHandler?
    private let inputAccessoryViewHeight: CGFloat = 44
    private var mnemonicImportHelper: MnemonicImportHelper!

    override func awakeFromNib() {
        super.awakeFromNib()
        configure()
    }

    override func applyTheme(_ theme: ThemeProtocol) {
        super.applyTheme(theme)
        textView.applyStyle(.body)
    }

    func update(
        with viewModel: MnemonicInputViewModel?,
        handler: @escaping InputHandler
    ) -> Self {
        self.viewModel = viewModel
        self.handler = handler
        refreshTextView()
        return self
    }
}

extension MnemonicImportCell: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        handler?(textView.text, textView.selectedRange.location)
    }
}

private extension MnemonicImportCell {
    
    func configure() {
        applyTheme(Theme)
        textView.delegate = self

        mnemonicImportHelper = MnemonicImportHelper(
            textView: textView,
            onMnemonicChangedHandler: { [weak self] newMnemonic, cursorLocation in
                self?.handler?(newMnemonic, cursorLocation)
            }
        )
        textView.inputAccessoryView = mnemonicImportHelper.inputAccessoryView(
            size: .init(width: contentView.frame.width, height: inputAccessoryViewHeight)
        )
        let toolbar = UIToolbar.keyboardToolbar()
        textView.inputAccessoryView = toolbar.wrapInInputView()
    }
}

private extension MnemonicImportCell {
    
    func refreshTextView() {
        guard let viewModel = self.viewModel else { return }
        if let text = viewModel.mnemonicToUpdate { textView.text = text }
        let selectedRange = textView.selectedRange
        let attributedText = NSMutableAttributedString(
            string: textView.text,
            attributes: [
                .font: Theme.font.body,
                .foregroundColor: Theme.color.textPrimary
            ]
        )
        var location = 0
        var hasInvalidWords = false
        for wordInfo in viewModel.wordsInfo {
            guard wordInfo.isInvalid else {
                location += wordInfo.word.count + 1
                continue
            }
            attributedText.setAttributes(
                [
                    .foregroundColor: Theme.color.navBarTint,
                    .font: Theme.font.body
                ],
                range: .init(location: location, length: wordInfo.word.count)
            )
            location += wordInfo.word.count + 1
            hasInvalidWords = true
        }
        textView.attributedText = attributedText
        layer.borderWidth = hasInvalidWords ? 2 : 0
        layer.borderColor = hasInvalidWords ? Theme.color.navBarTint.cgColor : nil
        layer.cornerRadius = Theme.cornerRadius
        textView.inputAccessoryView?.removeAllSubview()
        mnemonicImportHelper.addWords(
            viewModel.potentialWords,
            to: textView.inputAccessoryView
        )
        textView.selectedRange = selectedRange
    }
}
