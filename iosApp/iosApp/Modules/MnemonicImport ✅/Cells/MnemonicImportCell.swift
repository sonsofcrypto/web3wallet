// Created by web3d3v on 13/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

final class MnemonicImportCell: CollectionViewCell {
    typealias OnMnemonicChanged = ((mnemonic: String, selectedLocation: Int)) -> Void

    @IBOutlet weak var textView: UITextView!
    
    struct Handler {
        let onMnemonicChanged: OnMnemonicChanged
    }

    private var viewModel: MnemonicImportViewModel.SectionMnemonic!
    private var handler: Handler!
    
    private let inputAccessoryViewHeight: CGFloat = 40
    private var mnemonicImportHelper: MnemonicImportHelper!

    override func awakeFromNib() {
        super.awakeFromNib()
        configure()
    }
    
    override func setSelected(_ selected: Bool) {}

    func update(
        with viewModel: MnemonicImportViewModel.SectionMnemonic,
        handler: Handler
    ) -> MnemonicImportCell {
        self.viewModel = viewModel
        self.handler = handler
        textView.isEditable = true
        textView.isUserInteractionEnabled = true
        refreshTextView()
        return self
    }
}

extension MnemonicImportCell: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        handler.onMnemonicChanged((textView.text, textView.selectedRange.location))
    }
}

private extension MnemonicImportCell {
    
    func configure() {
        mnemonicImportHelper = MnemonicImportHelper(
            textView: textView,
            onMnemonicChangedHandler: { [weak self] newMnemonic, selectedLocation in
                self?.handler.onMnemonicChanged((newMnemonic, selectedLocation))
            }
        )
        textView.delegate = self
        textView.applyStyle(.body)
        textView.backgroundColor = .clear
        textView.inputAccessoryView = mnemonicImportHelper.inputAccessoryView(
            size: .init(width: contentView.frame.width, height: inputAccessoryViewHeight)
        )
    }
}

private extension MnemonicImportCell {
    
    func refreshTextView() {
        if let text = viewModel.mnemonicToUpdate { textView.text = text }
        let selectedRange = textView.selectedRange
        let attributedText = NSMutableAttributedString(
            string: textView.text,
            attributes: [
                .font: Theme.font.body,
                .foregroundColor: Theme.colour.labelPrimary
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
                    .foregroundColor: Theme.colour.navBarTint,
                    .font: Theme.font.body
                ],
                range: .init(
                    location: location,
                    length: wordInfo.word.count
                )
            )
            location += wordInfo.word.count + 1
            hasInvalidWords = true
        }
        textView.attributedText = attributedText
        layer.borderWidth = hasInvalidWords ? 2 : 0
        layer.borderColor = hasInvalidWords ? Theme.colour.navBarTint.cgColor : nil
        textView.inputAccessoryView?.removeAllSubview()
        mnemonicImportHelper.addWords(viewModel.potentialWords, to: textView.inputAccessoryView)
        textView.selectedRange = selectedRange
    }
}
