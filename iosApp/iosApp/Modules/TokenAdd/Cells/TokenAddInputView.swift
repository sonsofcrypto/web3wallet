// Created by web3d4v on 20/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

final class TokenAddInputView: UIView {
    
    private var nameLabel: UILabel!
    private var textField: TextField!
    private var hintLabel: UILabel!
    private var actionsView: UIView!
    private var pasteAction: UIButton!
    
    private var viewModel: TokenAddViewModel.TextFieldItem!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        configureUI()
    }
    
    func update(
        with viewModel: TokenAddViewModel.TextFieldItem,
        keyboardType: UIKeyboardType = .default,
        returnType: UIReturnKeyType = .next,
        autocapitalizationType: UITextAutocapitalizationType = .none
    ) {
        
        self.viewModel = viewModel
        
        nameLabel.text = viewModel.item.name
        
        if let value = viewModel.item.value {
            
            textField.text = value
        }
        textField.tag = viewModel.tag
        textField.placeholderAttrText = viewModel.placeholder
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
    
    func makeInputStack() -> UIStackView {
                
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = Theme.constant.padding.half.half
        
        let nameLabel = UILabel()
        nameLabel.font =  Theme.font.footnote
        nameLabel.textColor = Theme.colour.labelSecondary
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
        hintLabel.textColor = Theme.colour.navBarTint
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
        pasteAction.setTitle(Localized("paste"), for: .normal)
        pasteAction.titleLabel?.font = Theme.font.subheadlineBold
        pasteAction.setTitleColor(Theme.colour.labelPrimary, for: .normal)
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
        
        guard let textFieldType = TokenAddViewModel.TextFieldType(rawValue: textField.tag) else { return }
        textField.text = UIPasteboard.general.string
        viewModel.onTextChanged(textFieldType, textField.text ?? "")
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
