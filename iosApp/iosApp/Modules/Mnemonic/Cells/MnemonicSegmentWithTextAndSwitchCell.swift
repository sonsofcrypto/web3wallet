// Created by web3d3v on 13/04/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

class MnemonicSegmentWithTextAndSwitchCell: CollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var switchLabel: UILabel!
    @IBOutlet weak var onOffSwitch: UISwitch!
    @IBOutlet weak var vStack: UIStackView!
    @IBOutlet weak var hStack: UIStackView!

    var selectSegmentAction: ((Int) -> Void)?
    var textChangeHandler: ((String)->Void)?
    var switchAction: ((Bool)->Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        configureUI()
    }

    func configureUI() {
        
        titleLabel.font = Theme.font.body
        titleLabel.textColor = Theme.colour.labelPrimary
        
        switchLabel.font = Theme.font.body
        switchLabel.textColor = Theme.colour.labelPrimary
        
        textField.backgroundColor = Theme.colour.labelQuaternary
        textField.font = Theme.font.body
        textField.textColor = Theme.colour.labelSecondary
        textField.delegate = self
        
        onOffSwitch.addTarget(
            self,
            action: #selector(switchAction(_:)),
            for: .valueChanged
        )
        
        segmentControl.selectedSegmentTintColor = Theme.colour.labelQuaternary
        segmentControl.tintColor = Theme.colour.labelQuaternary
        segmentControl.setTitleTextAttributes(
            [
                NSAttributedString.Key.font: Theme.font.footnote,
                NSAttributedString.Key.foregroundColor: Theme.colour.labelPrimary
            ],
            for: .normal
        )
        segmentControl.addTarget(
            self,
            action: #selector(segmentAction(_:)),
            for: .valueChanged
        )
    }

    @objc func switchAction(_ sender: UISwitch) {
        switchAction?(sender.isOn)
    }

    @objc func segmentAction(_ sender: UISegmentedControl) {
        selectSegmentAction?(sender.selectedSegmentIndex)
    }
}

extension MnemonicSegmentWithTextAndSwitchCell: UITextFieldDelegate {

    func textFieldDidEndEditing(_ textField: UITextField) {
        textChangeHandler?(textField.text ?? "")
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        textChangeHandler?(textField.text ?? "")
        return false
    }
}

extension MnemonicSegmentWithTextAndSwitchCell {

    func update(
        with viewModel: MnemonicViewModel.SegmentWithTextAndSwitchInput,
        selectSegmentAction: ((Int) -> Void)?,
        textChangeHandler: ((String)->Void)?,
        switchHandler: ((Bool)->Void)?
    ) -> MnemonicSegmentWithTextAndSwitchCell {
        titleLabel.text = viewModel.title
        textField.text = viewModel.password
        (textField as? TextField)?.placeholderAttrText = viewModel.placeholder
        switchLabel.text = viewModel.onOffTitle
        onOffSwitch.setOn(viewModel.onOff, animated: false)

//        vStack.setCustomSpacing(viewModel.onOff ? 2 : 2, after: hStack)

        self.selectSegmentAction = selectSegmentAction
        self.textChangeHandler = textChangeHandler
        self.switchAction = switchHandler

        for (idx, item) in viewModel.segmentOptions.enumerated() {
            if segmentControl.numberOfSegments <= idx {
                segmentControl.insertSegment(withTitle: item, at: idx, animated: false)
            } else {
                segmentControl.setTitle(item, forSegmentAt: idx)
            }
        }

        segmentControl.selectedSegmentIndex = viewModel.selectedSegment

        return self
    }
}
