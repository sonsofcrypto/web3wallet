// Created by web3d4v on 20/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

final class CurrencyAddInputView: UIView {
    
    struct Handler {
        let onTextChanged: (CurrencyAddViewModel.TextFieldType, String) -> Void
        let onReturnTapped: (CurrencyAddViewModel.TextFieldType) -> Void
        let onPaste: (CurrencyAddViewModel.TextFieldType, String) -> Void
    }
    
    private var nameLabel: UILabel!
    private var textField: TextField!
    private var hintLabel: UILabel!
    private var actionsView: UIView!
    private var pasteAction: UIButton!
    
    private var viewModel: CurrencyAddViewModel.TextFieldItem!
    private var handler: Handler!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureUI()
    }
    
    func update(
        with viewModel: CurrencyAddViewModel.TextFieldItem,
        handler: Handler,
        keyboardType: UIKeyboardType = .default,
        returnType: UIReturnKeyType = .next,
        autocapitalizationType: UITextAutocapitalizationType = .none
    ) {
        self.viewModel = viewModel
        self.handler = handler
        nameLabel.text = viewModel.name
        if let value = viewModel.value { textField.text = value }
        textField.placeholderAttrText = viewModel.placeholder
        textField.keyboardType = keyboardType
        textField.returnKeyType = returnType
        textField.autocapitalizationType = autocapitalizationType
        if viewModel.isFirstResponder { textField.becomeFirstResponder() }
        if let hint = viewModel.hint {
            hintLabel.isHidden = false
            hintLabel.text = hint
        } else { hintLabel.isHidden = true }
    }
    
    @discardableResult
    override func resignFirstResponder() -> Bool {
        textField.resignFirstResponder()
    }
}

private extension CurrencyAddInputView {
    
    func configureUI() {
        backgroundColor = .clear
        let inputStack = inputStack()
        self.actionsView = _actionsView()
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = Theme.constant.padding.half
        stackView.addArrangedSubview(inputStack)
        stackView.addArrangedSubview(actionsView)
        addSubview(stackView)
        stackView.addConstraints(
            [
                .layout(anchor: .leadingAnchor),
                .layout(anchor: .trailingAnchor),
                .layout(anchor: .topAnchor),
                .layout(anchor: .bottomAnchor)
            ]
        )
        let tapGesture = UITapGestureRecognizer(target: textField, action: #selector(becomeFirstResponder))
        addGestureRecognizer(tapGesture)
    }
    
    func inputStack() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = Theme.constant.padding.half.half
        let nameLabel = UILabel()
        nameLabel.font =  Theme.font.footnote
        nameLabel.textColor = Theme.color.textSecondary
        stackView.addArrangedSubview(nameLabel)
        self.nameLabel = nameLabel
        let textField = TextField()
        textField.borderStyle = .none
        textField.autocorrectionType = .no
        textField.spellCheckingType = .no
        textField.clearButtonMode = .whileEditing
        textField.addDoneInputAccessoryView(
            with: .targetAction(.init(target: self, selector: #selector(dismissKeyboard)))
        )
        textField.delegate = self
        stackView.addArrangedSubview(textField)
        self.textField = textField
        let hintLabel = UILabel()
        hintLabel.font = Theme.font.caption1
        hintLabel.textColor = Theme.color.textPrimary
        hintLabel.isHidden = true
        stackView.addArrangedSubview(hintLabel)
        self.hintLabel = hintLabel
        return stackView
    }
    
    func _actionsView() -> UIView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 16
        let pasteAction = UIButton(type: .custom)
        pasteAction.setTitle(Localized("paste"), for: .normal)
        pasteAction.titleLabel?.font = Theme.font.subheadlineBold
        pasteAction.setTitleColor(Theme.color.textPrimary, for: .normal)
        pasteAction.addTarget(self, action: #selector(pasteActionTapped), for: .touchUpInside)
        pasteAction.addConstraints(
            [
                .hugging(layoutAxis: .horizontal, priority: .required),
                .compression(layoutAxis: .horizontal, priority: .required)
            ]
        )
        stackView.addArrangedSubview(pasteAction)
        self.pasteAction = pasteAction
        let view = UIView()
        view.backgroundColor = .clear
        view.addSubview(stackView)
        stackView.addConstraints(
            [
                .layout(anchor: .leadingAnchor),
                .layout(anchor: .trailingAnchor),
                .layout(anchor: .centerYAnchor),
                .hugging(axis: .horizontal, priority: .required)
            ]
        )
        return view
    }
    
    @objc func pasteActionTapped() {
        handler.onPaste(viewModel.type, UIPasteboard.general.string ?? "")
    }

    @objc func dismissKeyboard() {
        textField.resignFirstResponder()
    }
}

extension CurrencyAddInputView: UITextFieldDelegate {
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        handler.onTextChanged(viewModel.type, textField.text ?? "")
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handler.onReturnTapped(viewModel.type)
        return true
    }
}
