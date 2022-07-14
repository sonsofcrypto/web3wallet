// Created by web3d4v on 05/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

final class SwitchTextInputCollectionViewCell: CollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var onOffSwitch: UISwitch!
    @IBOutlet weak var textField: TextField!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var vStack: UIStackView!
    @IBOutlet weak var hStack: UIStackView!

    var switchAction: ((Bool)->Void)?
    var textChangeHandler: ((String)->Void)?
    var descriptionAction: (()->Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        configureUI()
    }

    func configureUI() {
        
        titleLabel.apply(style: .body)
        textField.delegate = self
        (textField as? TextField)?.textChangeHandler = { [weak self] text in
            self?.textChangeHandler?(text ?? "")
        }

        descriptionLabel.addGestureRecognizer(
            .init(target: self, action: #selector(descriptionAction(_:)))
        )
        onOffSwitch.addTarget(
            self,
            action: #selector(switchAction(_:)),
            for: .valueChanged
        )
    }

    @objc func switchAction(_ sender: UISwitch) {
        switchAction?(sender.isOn)
    }

    @objc func descriptionAction(_ sender: Any) {
        descriptionAction?()
    }
}

extension SwitchTextInputCollectionViewCell: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}

// MARK: - Update with viewModel

extension SwitchTextInputCollectionViewCell {

    func update(
        with viewModel: MnemonicNewViewModel.SwitchWithTextInput,
        switchAction: ((Bool)->Void)?,
        textChangeHandler: ((String)->Void)?,
        descriptionAction: (()->Void)?
    ) -> Self {
        update(
            title: viewModel.title,
            onOff: viewModel.onOff,
            text: viewModel.text,
            placeholder: viewModel.placeholder,
            description: viewModel.description,
            descriptionHighlightedWords: viewModel.descriptionHighlightedWords,
            switchAction: switchAction,
            textChangeHandler: textChangeHandler,
            descriptionAction: descriptionAction
        )
        return self
    }

    func update(
        with viewModel: MnemonicUpdateViewModel.SwitchWithTextInput,
        switchAction: ((Bool)->Void)?,
        textChangeHandler: ((String)->Void)?,
        descriptionAction: (()->Void)?
    ) -> Self {
        update(
            title: viewModel.title,
            onOff: viewModel.onOff,
            text: viewModel.text,
            placeholder: viewModel.placeholder,
            description: viewModel.description,
            descriptionHighlightedWords: viewModel.descriptionHighlightedWords,
            switchAction: switchAction,
            textChangeHandler: textChangeHandler,
            descriptionAction: descriptionAction
        )
        return self
    }

    func update(
        with viewModel: MnemonicImportViewModel.SwitchWithTextInput,
        switchAction: ((Bool)->Void)?,
        textChangeHandler: ((String)->Void)?,
        descriptionAction: (()->Void)?
    ) -> Self {
        update(
            title: viewModel.title,
            onOff: viewModel.onOff,
            text: viewModel.text,
            placeholder: viewModel.placeholder,
            description: viewModel.description,
            descriptionHighlightedWords: viewModel.descriptionHighlightedWords,
            switchAction: switchAction,
            textChangeHandler: textChangeHandler,
            descriptionAction: descriptionAction
        )
        return self
    }
}

// MARK: - Utilities

private extension SwitchTextInputCollectionViewCell {

    func update(
        title: String,
        onOff: Bool,
        text: String,
        placeholder: String,
        description: String,
        descriptionHighlightedWords: [String],
        switchAction: ((Bool)->Void)?,
        textChangeHandler: ((String)->Void)?,
        descriptionAction: (()->Void)?
    ) {
        titleLabel.text = title
        onOffSwitch.setOn(onOff, animated: false)
        textField.text = text

        textField.placeholderAttrText = placeholder

        let attrStr = NSMutableAttributedString(
            string: description,
            attributes: sectionFooter()
        )

        var hlAttrs  = sectionFooter()
        hlAttrs[.foregroundColor] = Theme.colour.fillPrimary

        descriptionHighlightedWords.forEach {
            let range = NSString(string: description).range(of: $0)
            attrStr.setAttributes(hlAttrs, range: range)
        }

        descriptionLabel.attributedText = attrStr
        vStack.setCustomSpacing(onOff ? 2 : 2, after: hStack)

        self.switchAction = switchAction
        self.textChangeHandler = textChangeHandler
        self.descriptionAction = descriptionAction
    }

    func sectionFooter() -> [NSAttributedString.Key: Any] {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6
        
        return [
            .font: Theme.font.callout,
            .foregroundColor: Theme.colour.labelTertiary,
            .paragraphStyle: paragraphStyle
        ]
    }
}
