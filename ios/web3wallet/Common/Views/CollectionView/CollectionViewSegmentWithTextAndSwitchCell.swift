// Created by web3d3v on 13/04/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

class CollectionViewSegmentWithTextAndSwitchCell: CollectionViewCell {

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
        titleLabel.applyStyle(.bodyGlow)
        switchLabel.applyStyle(.bodyGlow)
        textField.delegate = self
        onOffSwitch.addTarget(
            self,
            action: #selector(switchAction(_:)),
            for: .valueChanged
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

// MARK: - UITextFieldDelegate

extension CollectionViewSegmentWithTextAndSwitchCell: UITextFieldDelegate {

    func textFieldDidEndEditing(_ textField: UITextField) {
        textChangeHandler?(textField.text ?? "")
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        textChangeHandler?(textField.text ?? "")
        return false
    }
}

// MARK: - CollectionViewSegmentWithTextAndSwitchCell

extension CollectionViewSegmentWithTextAndSwitchCell {

    func update(
        with viewModel: NewMnemonicViewModel.SegmentWithTextAndSwitchInput,
        selectSegmentAction: ((Int) -> Void)?,
        textChangeHandler: ((String)->Void)?,
        switchHandler: ((Bool)->Void)?
    ) -> CollectionViewSegmentWithTextAndSwitchCell {
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
