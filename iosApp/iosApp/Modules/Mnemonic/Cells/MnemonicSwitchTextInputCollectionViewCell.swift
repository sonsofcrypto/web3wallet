// Created by web3d4v on 05/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

final class MnemonicSwitchTextInputCollectionViewCell: CollectionViewCell {

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

extension MnemonicSwitchTextInputCollectionViewCell: UITextFieldDelegate {


    func textFieldDidEndEditing(_ textField: UITextField) {
        textChangeHandler?(textField.text ?? "")
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        textChangeHandler?(textField.text ?? "")
        return false
    }
}

extension MnemonicSwitchTextInputCollectionViewCell {

    func update(
        with viewModel: MnemonicViewModel.SwitchWithTextInput,
        switchAction: ((Bool)->Void)?,
        textChangeHandler: ((String)->Void)?,
        descriptionAction: (()->Void)?
    ) -> Self {
        
        titleLabel.text = viewModel.title
        onOffSwitch.setOn(viewModel.onOff, animated: false)
        textField.text = viewModel.text

        (textField as? TextField)?.placeholderAttrText = viewModel.placeholder

        let attrStr = NSMutableAttributedString(
            string: viewModel.description,
            attributes: sectionFooter()
        )

        var hlAttrs  = sectionFooter()
        hlAttrs[.foregroundColor] = Theme.colour.fillPrimary

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
    
    private func sectionFooter() -> [NSAttributedString.Key: Any] {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6
        
        return [
            .font: Theme.font.callout,
            .foregroundColor: Theme.colour.labelTertiary,
            .paragraphStyle: paragraphStyle
        ]
    }
}
