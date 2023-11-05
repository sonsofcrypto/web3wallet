// Created by web3d4v on 05/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

final class SwitchTextInputCollectionViewCell: ThemeCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var onOffSwitch: OnOffSwitch!
    @IBOutlet weak var textField: TextField!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var vStack: UIStackView!
    @IBOutlet weak var hStack: UIStackView!

    private var switchAction: ((Bool)->Void)?
    private var inputHandler: ((String)->Void)?
    private var descriptionAction: (()->Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
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

    override func applyTheme(_ theme: ThemeProtocol) {
        super.applyTheme(theme)
        titleLabel.apply(style: .body)
    }

    func update(
        with viewModel: CellViewModel.SwitchTextInput,
        switchHandler: ((Bool)->Void)?,
        inputHandler: ((String)->Void)?,
        learnMoreHandler: (()->Void)?
    ) -> Self {
        titleLabel.text = viewModel.title
        onOffSwitch.setOn(viewModel.onOff, animated: false)
        textField.text = viewModel.text
        textField.placeholderAttrText = viewModel.placeholder

        var hlAttrs  = descriptionAttrs()
        hlAttrs[.foregroundColor] = Theme.color.textSecondary

        let attrStr = NSMutableAttributedString(
            string: viewModel.description,
            attributes: descriptionAttrs()
        )

        viewModel.descriptionHighlightedWords.forEach {
            let range = NSString(string: description).range(of: $0)
            attrStr.setAttributes(hlAttrs, range: range)
        }

        descriptionLabel.attributedText = attrStr
        vStack.setCustomSpacing(2, after: hStack)

        self.switchAction = switchHandler
        self.inputHandler = inputHandler
        self.descriptionAction = learnMoreHandler
        return self
    }

    @objc func switchAction(_ sender: UISwitch) {
        switchAction?(sender.isOn)
    }

    @objc func descriptionAction(_ sender: Any) {
        descriptionAction?()
    }

    private func descriptionAttrs() -> [NSAttributedString.Key: Any] {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6
        return [
            .font: Theme.font.callout,
            .foregroundColor: Theme.color.textTertiary,
            .paragraphStyle: paragraphStyle
        ]
    }
}

extension SwitchTextInputCollectionViewCell: UITextFieldDelegate {

    func textFieldDidChangeSelection(_ textField: UITextField) {
        inputHandler?(textField.text ?? "")
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}
