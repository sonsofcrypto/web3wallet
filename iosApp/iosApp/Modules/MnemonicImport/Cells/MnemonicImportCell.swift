// Created by web3d3v on 13/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

final class MnemonicImportCell: CollectionViewCell {
    
    typealias OnMnemonicChanged = (
        (
            mnemonic: String,
            selectedLocation: Int
        )
    ) -> Void

    @IBOutlet weak var textView: UITextView!
    
    struct Handler {
        
        let onMnemonicChanged: OnMnemonicChanged
    }

    private var viewModel: MnemonicImportViewModel.Mnemonic!
    private var handler: Handler!
    
    private let inputAccessoryViewHeight: CGFloat = 40

    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        configure()
    }
    
    override func setSelected(_ selected: Bool) {}

    func update(
        with viewModel: MnemonicImportViewModel.Mnemonic,
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
        
        handler.onMnemonicChanged(
            (
                mnemonic: textView.text,
                selectedLocation: textView.selectedRange.location
            )
        )
    }
}

private extension MnemonicImportCell {
    
    func configure() {
        
        textView.delegate = self
        textView.applyStyle(.body)
        textView.backgroundColor = .clear
        textView.inputAccessoryView = makeInputAccessoryView()
    }
    
    func makeInputAccessoryView() -> UIView {
        
        let scrollView = UIScrollView(
            frame: .init(
                origin: .zero,
                size: .init(
                    width: contentView.frame.width,
                    height: inputAccessoryViewHeight
                )
            )
        )
        scrollView.backgroundColor = Theme.colour.navBarBackground
        addWords([], to: scrollView)
        return scrollView
    }
    
    func addWords(_ words: [String], to view: UIView?) {
        
        guard let view = view else { return }
        
        var labels = [UILabel]()
        for (index, word) in words.enumerated() {
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
    
    @objc func wordSelectedFromInputView(sender: UITapGestureRecognizer) {
        
        guard let index = sender.view?.tag else { return }
        
        guard viewModel.potentialWords.count > index else { return }
        
        let word = viewModel.potentialWords[index]
        
        let newMnemonic = makeNewMnemonic(appendingWord: word)
        textView.text = newMnemonic
        
        handler.onMnemonicChanged(
            (
                mnemonic: newMnemonic,
                selectedLocation: textView.selectedRange.location
            )
        )
    }
    
    func makeNewMnemonic(appendingWord word: String) -> String {

        guard let text = textView.text, !text.isEmpty else {
            return word + " "
        }

        if textView.selectedRange.location == text.count {
            
            if let lastCharacter = text.last, lastCharacter == " " {
                return textView.text + word + " "
            } else {
                var words = text.split(separator: " ")
                _ = words.removeLast()
                return words.joined(separator: " ") + " " + word + " "
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

private extension MnemonicImportCell {
    
    func refreshTextView() {
        
        if let text = viewModel.mnemonicToUpdate {
            textView.text = text
        }
        
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
        addWords(viewModel.potentialWords, to: textView.inputAccessoryView)
        
        textView.selectedRange = selectedRange
    }
}
