// Created by web3d3v on 12/04/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

class CollectionViewSwitchTextInputCell: CollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var onOffSwitch: UISwitch!
    @IBOutlet weak var textField: UITextField!
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
        titleLabel.applyStyle(.bodyGlow)
        textField.delegate = self

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

// MARK: - UITextFieldDelegate

extension CollectionViewSwitchTextInputCell: UITextFieldDelegate {


    func textFieldDidEndEditing(_ textField: UITextField) {
        textChangeHandler?(textField.text ?? "")
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        textChangeHandler?(textField.text ?? "")
        return false
    }
}

// MARK: - CollectionViewSwitchTextInputCell

extension CollectionViewSwitchTextInputCell {

    func update(
        with viewModel: NewMnemonicViewModel.SwitchWithTextInput,
        switchAction: ((Bool)->Void)?,
        textChangeHandler: ((String)->Void)?,
        descriptionAction: (()->Void)?
    ) -> CollectionViewSwitchTextInputCell {
        titleLabel.text = viewModel.title
        onOffSwitch.setOn(viewModel.onOff, animated: false)
        textField.text = viewModel.text

        (textField as? TextField)?.placeholderAttrText = viewModel.placeholder

        let attrStr = NSMutableAttributedString(
            string: viewModel.description,
            attributes: Theme.current.sectionFooterTextAttributes()
        )

        var hlAttrs  = Theme.current.sectionFooterTextAttributes()
        hlAttrs[.foregroundColor] = Theme.current.tintPrimary

        viewModel.descriptionHighlightedWords.forEach {
            let range = NSString(string: viewModel.description).range(of: $0)
            attrStr.setAttributes(hlAttrs, range: range)
        }

        descriptionLabel.attributedText = attrStr
        vStack.setCustomSpacing(viewModel.onOff ? 2 : 2, after: hStack)
        
        self.switchAction = switchAction
        self.textChangeHandler = textChangeHandler
        self.descriptionAction = descriptionAction

        return self
    }
}
