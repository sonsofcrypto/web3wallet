// Created by web3d4v on 12/05/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import WebKit

protocol MnemonicConfirmationView: AnyObject {
    
    func update(with viewModel: MnemonicConfirmationViewModel)
}

final class MnemonicConfirmationViewController: UIViewController {
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var button: Button!

    var presenter: MnemonicConfirmationPresenter!
    
    private var viewModel: MnemonicConfirmationViewModel!
    private let inputAccessoryViewHeight: CGFloat = 40
        
    override func viewDidLoad() {
        
        super.viewDidLoad()
    
        configureUI()
        
        presenter.present()
    }
}

extension MnemonicConfirmationViewController {
    
    @IBAction func ctaAction(_ sender: Any) {
        
        presenter.handle(.confirm)
    }
}

extension MnemonicConfirmationViewController: MnemonicConfirmationView {
    
    func update(with viewModel: MnemonicConfirmationViewModel) {
        
        self.viewModel = viewModel
        
        refresh()
    }
}

extension MnemonicConfirmationViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        
        presenter.handle(
            .mnemonicChanged(
                to: textView.text,
                selectedLocation: textView.selectedRange.location
            )
        )
    }
}

private extension MnemonicConfirmationViewController {
    
    func configureUI() {
        
        view.add(.targetAction(.init(target: self, selector: #selector(dismissKeyboard))))
        
        title = Localized("mnemonicConfirmation.title")
        (view as? GradientView)?.colors = [
            Theme.colour.backgroundBaseSecondary,
            Theme.colour.backgroundBasePrimary
        ]
        
        statusLabel.text = Localized("mnemonicConfirmation.confirm.wallet")
        statusLabel.font = Theme.font.body
        statusLabel.textColor = Theme.colour.labelPrimary
        
        textView.delegate = self
        textView.backgroundColor = Theme.colour.backgroundBaseSecondary.withAlpha(0.8)
        textView.font = Theme.font.body
        textView.textColor = Theme.colour.labelPrimary
        textView.inputAccessoryView = makeInputAccessoryView()

        button.setTitle(Localized("mnemonicConfirmation.title"), for: .normal)
        button.setTitle(Localized("mnemonicConfirmation.title"), for: .disabled)
        button.isEnabled = false
    }
    
    @objc func dismissKeyboard() {
        
        textView.resignFirstResponder()
    }
}

private extension MnemonicConfirmationViewController {
    
    func refresh() {
        
        refreshTextView()
        refreshCTA()
    }
    
    func refreshTextView() {
        
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
                    .foregroundColor: Theme.colour.systemRed,
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
        
        textView.layer.borderWidth = hasInvalidWords ? 2 : 0
        textView.layer.borderColor = hasInvalidWords ? Theme.colour.systemRed.cgColor : nil
        
        textView.inputAccessoryView?.clearSubviews()
        addWords(viewModel.potentialWords, to: textView.inputAccessoryView)
        
        textView.selectedRange = selectedRange
    }
    
    func refreshCTA() {
        
        button.isEnabled = viewModel.isValid
    }
}

private extension MnemonicConfirmationViewController {
    
    func makeInputAccessoryView() -> UIView {
        
        let scrollView = UIScrollView(
            frame: .init(
                origin: .zero,
                size: .init(
                    width: view.frame.width,
                    height: inputAccessoryViewHeight
                )
            )
        )
        scrollView.backgroundColor = Theme.colour.backgroundBaseSecondary.withAlpha(0.8)
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
        presenter.handle(
            .mnemonicChanged(
                to: newMnemonic,
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
