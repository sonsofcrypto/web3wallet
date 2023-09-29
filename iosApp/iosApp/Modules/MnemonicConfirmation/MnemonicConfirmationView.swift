// Created by web3d4v on 12/05/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

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
    private var mnemonicImportHelper: MnemonicImportHelper!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        presenter.present()
    }
}

extension MnemonicConfirmationViewController {
    
    @IBAction func ctaAction(_ sender: Any) {
        presenter.handleEvent(MnemonicConfirmationPresenterEvent.Confirm())
    }
}

extension MnemonicConfirmationViewController {
    
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
        presenter.handleEvent(
            .MnemonicChanged(
                to: textView.text,
                selectedLocation: textView.selectedRange.location.int32
            )
        )
    }
}

private extension MnemonicConfirmationViewController {
    
    func configureUI() {
        mnemonicImportHelper = MnemonicImportHelper(
            textView: textView,
            onMnemonicChangedHandler: { [weak self] newMnemonic, selectedLocation in
                self?.presenter.handleEvent(
                    .MnemonicChanged(
                        to: newMnemonic,
                        selectedLocation: selectedLocation.int32
                    )
                )
            }
        )
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
        statusLabel.textColor = Theme.color.textPrimary
        statusLabel.textAlignment = .left
        textViewContainer.backgroundColor = Theme.color.bgPrimary
        textViewContainer.layer.cornerRadius = Theme.cornerRadiusSmall
        textView.delegate = self
        textView.applyStyle(.body)
        textView.inputAccessoryView = mnemonicImportHelper.inputAccessoryView(
            size: .init(width: view.frame.width, height: inputAccessoryViewHeight)
        )
        saltLabel.text = Localized("mnemonicConfirmation.salt")
        saltLabel.apply(style: .headline)
        saltTextFieldView.backgroundColor = Theme.color.bgPrimary
        saltTextFieldView.layer.cornerRadius = Theme.cornerRadiusSmall
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

    @objc func dismissTapped() { presenter.handleEvent(MnemonicConfirmationPresenterEvent.Dismiss()) }
}

private extension MnemonicConfirmationViewController {
    
    func refresh() {
        refreshTextView()
        saltContainer.isHidden = !viewModel.showSalt
        refreshCTA()
    }
    
    func refreshTextView() {
        if let text = viewModel.mnemonicToUpdate {
            textView.text = text
        }
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
        textViewContainer.layer.borderColor = hasInvalidWords ? Theme.color.navBarTint.cgColor : nil
        textView.inputAccessoryView?.removeAllSubview()
        mnemonicImportHelper.addWords(viewModel.potentialWords, to: textView.inputAccessoryView)
        textView.selectedRange = selectedRange
    }
    
    func refreshCTA() {
        guard let isValid = viewModel.isValid?.boolValue else {
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

extension MnemonicConfirmationViewController: UITextFieldDelegate {
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        presenter.handleEvent(MnemonicConfirmationPresenterEvent.SaltChanged(to: textField.text ?? ""))
    }
}
