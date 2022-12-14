// Created by web3d4v on 21/11/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import UIKit

final class MnemonicImportHelper {
    
    let textView: UITextView
    let onMnemonicChangedHandler: (String, Int) -> Void
    
    init(
        textView: UITextView,
        onMnemonicChangedHandler: @escaping (String, Int) -> Void
    ) {
        self.textView = textView
        self.onMnemonicChangedHandler = onMnemonicChangedHandler
    }
        
    private let inputAccessoryViewHeight: CGFloat = 40
    private var potentialWords: [String] = []
    
    func inputAccessoryView(size: CGSize) -> UIView {
        let scrollView = UIScrollView(
            frame: .init(
                origin: .zero,
                size: size
            )
        )
        scrollView.backgroundColor = Theme.color.navBarBackground
        addWords([], to: scrollView)
        return scrollView
    }
    
    func addWords(
        _ potentialWords: [String],
        to view: UIView?
    ) {
        guard let view = view else { return }
        self.potentialWords = potentialWords
        var labels = [UILabel]()
        for (index, word) in potentialWords.enumerated() {
            let label = UILabel(with: .body)
            label.text = word
            label.addConstraints(
                [
                    .hugging(axis: .horizontal)
                ]
            )
            label.add(
                .targetAction(.init(target: self, selector: #selector(wordSelectedFromInputView(sender:))))
            )
            label.tag = index
            label.sizeToFit()
            labels.append(label)
        }
        labels.append(.init())
        let stackView = HStackView(labels)
        stackView.spacing = 16
        view.addSubview(stackView)
        stackView.addConstraints(
            [
                .layout(anchor: .leadingAnchor, constant: .equalTo(constant: 16)),
                .layout(anchor: .trailingAnchor, constant: .equalTo(constant: 16)),
                .layout(anchor: .topAnchor),
                .layout(anchor: .bottomAnchor),
                .layout(
                    anchor: .heightAnchor,
                    constant: .equalTo(constant: inputAccessoryViewHeight)
                )
            ]
        )
    }
    
    @objc private func wordSelectedFromInputView(sender: UITapGestureRecognizer) {
        guard let index = sender.view?.tag else { return }
        guard potentialWords.count > index else { return }
        let word = potentialWords[index]
        let newMnemonic = self.newMnemonic(appendingWord: word)
        textView.text = newMnemonic
        onMnemonicChangedHandler(newMnemonic, textView.selectedRange.location)
    }
    
    private func newMnemonic(appendingWord word: String) -> String {
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
            } else if
                textView.selectedRange.location < i,
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
