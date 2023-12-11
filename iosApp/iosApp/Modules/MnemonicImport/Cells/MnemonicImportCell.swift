// Created by web3d3v on 13/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

final class MnemonicImportCell: ThemeCell, UICollectionViewDataSource,
    UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    typealias InputHandler = (_ mnemonic: String, _ cursorLocation: Int) -> Void

    @IBOutlet weak var textView: UITextView?

    private var viewModel: MnemonicInputViewModel?
    private var handler: InputHandler?
    private var toolbarCollectionView: UICollectionView?

    private var needsTextViewConfig: Bool = true
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configure()
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if superview != nil {
            configureTextViewIfNeeded()
        }
    }

    override func applyTheme(_ theme: ThemeProtocol) {
        super.applyTheme(theme)
        textView?.applyStyle(.body)
    }

    func update(
        with viewModel: MnemonicInputViewModel?,
        handler: @escaping InputHandler
    ) -> Self {
        self.viewModel = viewModel
        self.handler = handler
        applyTextAndAttributes()
        toolbarCollectionView?.collectionViewLayout.invalidateLayout()
        toolbarCollectionView?.performBatchUpdates { [weak toolbarCollectionView] in
            toolbarCollectionView?.reloadSections(IndexSet([0]))
        }
        return self
    }

    func configure() {
        configureTextViewIfNeeded()
    }
    
    private func configureTextViewIfNeeded() {
        // NOTE: For unknown reason `textView` outlet is not connected in
        // `awakeFromNib`
        guard let textView = self.textView else { return }
        guard needsTextViewConfig else { return }
        needsTextViewConfig = false
        applyTheme(Theme)
        let toolbar = UIToolbar.collectionViewToolbar()
        toolbarCollectionView = toolbar.items?.first?.customView as? UICollectionView
        textView.inputAccessoryView = toolbar.wrapInInputView()
        toolbarCollectionView?.register(PlainTextCell.self)
        toolbarCollectionView?.delegate = self
        toolbarCollectionView?.dataSource = self
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        viewModel?.potentialWords.count ?? 0
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeue(PlainTextCell.self, for: indexPath)
        let word = viewModel?.potentialWords[safe: indexPath.item] ?? ""
        return cell.update(with: word)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        guard let textView = textView else { return }
        let word = viewModel?.potentialWords[safe: indexPath.item] ?? ""
        let text = addWordToMnemonic(appendingWord: word)
        textView.text = text
        handler?(textView.text, textView.selectedRange.location)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        String.estimateSize(
            (viewModel?.potentialWords[safe: indexPath.item] ?? "") + " ",
            font: Theme.font.bodyBold,
            maxWidth: textView?.inputAccessoryView?.bounds.width ?? 300,
            extraHeight: Theme.padding
        )
    }
}

extension MnemonicImportCell: UITextViewDelegate {

    func textViewDidChange(_ textView: UITextView) {
        handler?(textView.text, textView.selectedRange.location)
    }
}

private extension MnemonicImportCell {
    
    func applyTextAndAttributes() {
        guard let viewModel = viewModel, let textView = textView else { return }
        if let text = viewModel.mnemonicToUpdate {
            textView.text = text
        }
        let selectedRange = textView.selectedRange
        let attributedText = NSMutableAttributedString(
            string: textView.text,
            attributes: textAttrs()
        )

        var location = 0
        var hasInvalidWords = false

        for wordInfo in viewModel.wordsInfo {
            guard wordInfo.isInvalid else {
                location += wordInfo.word.count + 1
                continue
            }
            let range = NSRange(location: location, length: wordInfo.word.count)
            attributedText.setAttributes(errTextAttrs(), range: range)
            location += wordInfo.word.count + 1
            hasInvalidWords = true
        }

        textView.attributedText = attributedText
        textView.selectedRange = selectedRange
        setErrorStyle(hasInvalidWords)
    }

    func setErrorStyle(_ error: Bool = false) {
        layer.borderWidth = error ? 2 : 0
        layer.borderColor = error ? Theme.color.navBarTint.cgColor : nil
        layer.cornerRadius = Theme.cornerRadius
    }

    func textAttrs() -> [NSAttributedString.Key : Any] {
        [
            .font: Theme.font.body,
            .foregroundColor: Theme.color.textPrimary
        ]
    }

    func errTextAttrs() -> [NSAttributedString.Key : Any] {
        [
            .font: Theme.font.body,
            .foregroundColor: Theme.color.navBarTint
        ]
    }

    func addWordToMnemonic(appendingWord word: String) -> String {
        guard let textView = textView else { return word + " " }
        guard let text = textView.text, !text.isEmpty else { return word + " " }
        if textView.selectedRange.location == text.count {
            if let lastCharacter = text.last, lastCharacter == " " {
                return textView.text + word + " "
            } else {
                var words = text.split(separator: " ")
                _ = words.removeLast()
                return words.joined(separator: " ") + (words.isEmpty ? "" : " ") + word + " "
            }
        }
        var newString = ""
        var lastWordCount = 0
        for var i in 0..<text.count {
            let character = text[text.index(text.startIndex, offsetBy: i)]
            if i == textView.selectedRange.location {
                newString.removeLast(lastWordCount)
                newString += word + " "
            } else if textView.selectedRange.location < i,
                  (textView.selectedRange.location + textView.selectedRange.length) >= i {
                // ignore character
            } else {
                newString.append(character)
            }
            i += 1
            lastWordCount += 1
            if character == " " {
                lastWordCount = 0
            }
        }
        return newString
    }
}
