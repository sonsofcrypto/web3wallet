// Created by web3d4v on 12/05/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import WebKit

protocol MnemonicConfirmationView: AnyObject {
    func update(with viewModel: MnemonicConfirmationViewModel)
}

final class MnemonicConfirmationViewController: UIViewController {
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var textViewContainer: UIView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var saltContainer: UIStackView!
    @IBOutlet weak var saltLabel: UILabel!
    @IBOutlet weak var saltTextFieldView: UIView!
    @IBOutlet weak var saltTextField: TextField!
    @IBOutlet weak var button: Button!

    var presenter: MnemonicConfirmationPresenter!
    
    private var viewModel: MnemonicConfirmationViewModel!
    private let inputAccessoryViewHeight: CGFloat = 40
    private var firstTime = true
        
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
        if firstTime {
            firstTime = false
            textView.becomeFirstResponder()
        }
    }
}

extension MnemonicConfirmationViewController: UITextViewDelegate {
    
    func textView(
        _ textView: UITextView,
        shouldChangeTextIn range: NSRange,
        replacementText text: String
    ) -> Bool {
        guard text == "\n" else { return true }
        textView.resignFirstResponder()
        return false
    }
    
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
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: .init(systemName: "xmark"),
            style: .plain,
            target: self,
            action: #selector(dismissTapped)
        )
        statusLabel.text = Localized("mnemonicConfirmation.confirm.wallet")
        statusLabel.font = Theme.font.body
        statusLabel.textColor = Theme.colour.labelPrimary
        statusLabel.textAlignment = .left
        textViewContainer.backgroundColor = Theme.colour.cellBackground
        textViewContainer.layer.cornerRadius = Theme.constant.cornerRadiusSmall
        textView.delegate = self
        textView.applyStyle(.body)
        textView.inputAccessoryView = inputAccessoryView()
        saltLabel.text = Localized("mnemonicConfirmation.salt")
        saltLabel.apply(style: .headline)
        saltTextFieldView.backgroundColor = Theme.colour.cellBackground
        saltTextFieldView.layer.cornerRadius = Theme.constant.cornerRadiusSmall
        saltTextField.backgroundColor = .clear
        saltTextField.text = nil
        saltTextField.delegate = self
        saltTextField.placeholderAttrText = Localized("mnemonicConfirmation.salt.placeholder")
        saltTextField.addDoneInputAccessoryView(
            with: .targetAction(.init(target: self, selector: #selector(dismissKeyboard)))
        )
        button.style = .primary
        button.setTitle(Localized("mnemonicConfirmation.cta"), for: .normal)
    }
    
    @objc func dismissKeyboard() { textView.resignFirstResponder() }

    @objc func dismissTapped() { presenter.handle(.dismiss) }
}

private extension MnemonicConfirmationViewController {
    
    func refresh() {
        refreshTextView()
        saltContainer.isHidden = !viewModel.showSalt
        refreshCTA()
    }
    
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
        textViewContainer.layer.borderWidth = hasInvalidWords ? 2 : 0
        textViewContainer.layer.borderColor = hasInvalidWords ? Theme.colour.navBarTint.cgColor : nil
        textView.inputAccessoryView?.removeAllSubview()
        addWords(viewModel.potentialWords, to: textView.inputAccessoryView)
        textView.selectedRange = selectedRange
    }
    
    func refreshCTA() {
        guard let isValid = viewModel.isValid else {
            button.setTitle(Localized("mnemonicConfirmation.cta"), for: .normal)
            return
        }
        
        if isValid {
            button.setTitle(Localized("mnemonicConfirmation.cta.congratulations"), for: .normal)
        } else {
            button.setTitle(Localized("mnemonicConfirmation.cta.invalid"), for: .normal)
        }
    }
}

private extension MnemonicConfirmationViewController {
    
    func inputAccessoryView() -> UIView {
        let scrollView = UIScrollView(
            frame: .init(
                origin: .zero,
                size: .init(
                    width: view.frame.width,
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
        let newMnemonic = self.newMnemonic(appendingWord: word)
        textView.text = newMnemonic
        presenter.handle(
            .mnemonicChanged(
                to: newMnemonic,
                selectedLocation: textView.selectedRange.location
            )
        )
    }
    
    func newMnemonic(appendingWord word: String) -> String {
        guard let text = textView.text, !text.isEmpty else { return word + " " }
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

extension MnemonicConfirmationViewController: UITextFieldDelegate {
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        presenter.handle(.saltChanged(to: textField.text ?? ""))
    }
}
