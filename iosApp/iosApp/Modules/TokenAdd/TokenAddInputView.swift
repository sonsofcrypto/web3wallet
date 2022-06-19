// Created by web3d4v on 20/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

final class TokenAddInputView: UIView {
    
    private var nameLabel: UILabel!
    private var textField: UITextField!
    private var hintLabel: UILabel!
    private var actionsView: UIView!
    private var pasteAction: UIButton!
    private var scanAction: UIButton!
    
    private var viewModel: TokenAddViewModel.TextFieldItem!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        configureUI()
    }
    
    func update(
        with viewModel: TokenAddViewModel.TextFieldItem,
        keyboardType: UIKeyboardType = .default,
        returnType: UIReturnKeyType = .next,
        autocapitalizationType: UITextAutocapitalizationType = .none,
        showScanAction: Bool = false
    ) {
        
        self.viewModel = viewModel
        
        nameLabel.text = viewModel.item.name
        
        if let value = viewModel.item.value {
            
            textField.text = value
        }
        textField.tag = viewModel.tag
        textField.placeholder = viewModel.placeholder
        textField.keyboardType = keyboardType
        textField.returnKeyType = returnType
        textField.autocapitalizationType = autocapitalizationType
        if viewModel.isFirstResponder {
            textField.becomeFirstResponder()
        }
        
        if let hint = viewModel.hint {
            
            hintLabel.isHidden = false
            hintLabel.text = hint
        } else {
            
            hintLabel.isHidden = true
        }
        
        scanAction.isHidden = viewModel.onScanAction == nil
    }
    
    @discardableResult
    override func resignFirstResponder() -> Bool {
        
        textField.resignFirstResponder()
    }
}

private extension TokenAddInputView {
    
    func configureUI() {
        
        backgroundColor = .clear
        
        let inputStack = makeInputStack()
        let actionsView = makeActionsView()
        self.actionsView = actionsView
        
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 16
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
    
    func makeInputStack() -> UIStackView {
                
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        
        let nameLabel = UILabel()
        nameLabel.applyStyle(.smallerLabel)
        nameLabel.textColor = Theme.color.textSecondary
        stackView.addArrangedSubview(nameLabel)
        self.nameLabel = nameLabel

        let textField = UITextField()
        textField.font = Theme.font.body
        textField.textColor = Theme.color.text
        textField.borderStyle = .none
        textField.autocorrectionType = .no
        textField.spellCheckingType = .no
        textField.clearButtonMode = .whileEditing
        textField.inputAccessoryView = makeInputAccessoryView()
        textField.delegate = self
        
        stackView.addArrangedSubview(textField)
        self.textField = textField

        let hintLabel = UILabel()
        hintLabel.applyStyle(.smallLabel)
        hintLabel.textColor = Theme.color.tint
        hintLabel.isHidden = true
        stackView.addArrangedSubview(hintLabel)
        self.hintLabel = hintLabel
        
        return stackView
    }
    
    func makeActionsView() -> UIView {
        
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 16
        
        let pasteAction = UIButton(type: .custom)
        pasteAction.setImage("paste_icon".assetImage, for: .normal)
        pasteAction.tintColor = Theme.color.tint
        pasteAction.addTarget(self, action: #selector(pasteActionTapped), for: .touchUpInside)
        pasteAction.addConstraints(
            [
                .layout(anchor: .widthAnchor, constant: .equalTo(constant: 24)),
                .layout(anchor: .heightAnchor, constant: .equalTo(constant: 24))
            ]
        )
        stackView.addArrangedSubview(pasteAction)
        self.pasteAction = pasteAction
        
        let scanAction = UIButton(type: .custom)
        scanAction.setImage("scan_icon".assetImage, for: .normal)
        scanAction.tintColor = Theme.color.tint
        scanAction.addTarget(self, action: #selector(scanActionTapped), for: .touchUpInside)
        scanAction.addConstraints(
            [
                .layout(anchor: .widthAnchor, constant: .equalTo(constant: 24)),
                .layout(anchor: .heightAnchor, constant: .equalTo(constant: 24))
            ]
        )
        stackView.addArrangedSubview(scanAction)
        self.scanAction = scanAction

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
        
        guard let textFieldType = TokenAddViewModel.TextFieldType(rawValue: textField.tag) else { return }
        textField.text = UIPasteboard.general.string
        viewModel.onTextChanged(textFieldType, textField.text ?? "")
    }
    
    @objc func scanActionTapped() {
        
        guard let textFieldType = TokenAddViewModel.TextFieldType(rawValue: textField.tag) else { return }
        viewModel.onScanAction?(textFieldType)
    }
    
    func makeInputAccessoryView() -> UIView {
        
        let view = UIView(
            frame: .init(
                origin: .zero,
                size: .init(
                    width: frame.width,
                    height: 40
                )
            )
        )
        view.backgroundColor = Theme.color.backgroundDark
        
        let doneAction = UIButton(type: .custom)
        doneAction.titleLabel?.font = Theme.font.body
        doneAction.titleLabel?.textAlignment = .right
        doneAction.setTitle(Localized("done"), for: .normal)
        doneAction.setTitleColor(Theme.color.tint, for: .normal)
        doneAction.addTarget(self, action: #selector(dismissKeyboard), for: .touchUpInside)
        view.addSubview(doneAction)
        doneAction.addConstraints(
            [
                .layout(anchor: .trailingAnchor, constant: .equalTo(constant: 16)),
                .layout(anchor: .centerYAnchor)
            ]
        )

        return view
    }
    
    @objc func dismissKeyboard() {
        
        textField.resignFirstResponder()
    }
}

extension TokenAddInputView: UITextFieldDelegate {
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        
        guard let textFieldType = TokenAddViewModel.TextFieldType(rawValue: textField.tag) else { return }
        viewModel.onTextChanged(textFieldType, textField.text ?? "")
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        guard let textFieldType = TokenAddViewModel.TextFieldType(rawValue: textField.tag) else { return false }
        viewModel.onReturnTapped(textFieldType)
        return true
    }
}
