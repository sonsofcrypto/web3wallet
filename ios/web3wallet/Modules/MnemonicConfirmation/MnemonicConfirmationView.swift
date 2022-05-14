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
        
        presenter.handle(.mnemonicChanged(to: textView.text))
    }
}

private extension MnemonicConfirmationViewController {
    
    func configureUI() {
        
        view.add(.targetAction(.init(target: self, selector: #selector(dismissKeyboard))))
        
        title = Localized("mnemonicConfirmation.title")
        (view as? GradientView)?.colors = [
            Theme.current.background,
            Theme.current.backgroundDark
        ]
        
        statusLabel.text = Localized("mnemonicConfirmation.confirm.wallet")
        statusLabel.font = Theme.current.body
        statusLabel.textColor = Theme.current.textColor
        
        textView.delegate = self
        textView.backgroundColor = Theme.current.background.withAlpha(0.8)
        textView.font = Theme.current.body
        textView.textColor = Theme.current.textColor
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
                        
        let attributedText = NSMutableAttributedString(
            string: textView.text,
            attributes: [
                .font: Theme.current.body,
                .foregroundColor: Theme.current.textColor
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
                    .foregroundColor: Theme.current.red,
                    .font: Theme.current.body
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
        textView.layer.borderColor = hasInvalidWords ? Theme.current.red.cgColor : nil
        
        textView.inputAccessoryView?.clearSubviews()
        addWords(viewModel.potentialWords, to: textView.inputAccessoryView)
    }
    
    func refreshCTA() {
        
        button.isEnabled = viewModel.isValid
    }
}

private extension MnemonicConfirmationViewController {
    
    func makeInputAccessoryView() -> UIView {
        
        let scrollView = UIScrollView(
            frame: .init(origin: .zero, size: .init(width: view.frame.width, height: 40))
        )
        scrollView.backgroundColor = Theme.current.background.withAlpha(0.8)
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
        
        let height = labels.first?.frame.size.height ?? 20
        
        let stackView = HStackView(labels)
        stackView.spacing = 12
        
        view.addSubview(stackView)
        
        stackView.addConstraints(
            [
                .layout(anchor: .leadingAnchor, constant: .equalTo(constant: 16)),
                .layout(anchor: .trailingAnchor, constant: .equalTo(constant: 16)),
                .layout(anchor: .topAnchor),
                .layout(anchor: .bottomAnchor),
                .layout(anchor: .heightAnchor, constant: .equalTo(constant: height))
            ]
        )
    }
    
    @objc func wordSelectedFromInputView(sender: UITapGestureRecognizer) {
        
        guard let index = sender.view?.tag else { return }
        
        guard viewModel.potentialWords.count > index else { return }
        
        let word = viewModel.potentialWords[index]
        
        let newMnemonic = makeNewMnemonic(appendingWord: word)
        textView.text = newMnemonic
        presenter.handle(.mnemonicChanged(to: newMnemonic))
    }
    
    func makeNewMnemonic(appendingWord word: String) -> String {
        
        var words = textView.text.split(separator: " ")
        
        if let lastCharacter = textView.text.last, lastCharacter == " " {
            
            return textView.text + word + " "
        } else if let lastWord = words.last {
            let text: String
            if let lastCharacter = textView.text.last, lastCharacter == " " {
                text = textView.text.replacingOccurrences(of: lastWord + " ", with: "")
            } else {
                
                _ = words.removeLast()
                text = words.joined(separator: " ")
            }
            return text + " " + word + " "
        } else {
            let afterTextSpace = textView.text.isEmpty ? "" : " "
            return textView.text + afterTextSpace + word + " "
        }
    }
}
