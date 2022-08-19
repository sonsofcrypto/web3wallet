// Created by web3d3v on 13/04/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

final class SegmentWithTextAndSwitchCell: CollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var segmentControl: SegmentedControl!
    @IBOutlet weak var textField: TextField!
    @IBOutlet weak var switchLabel: UILabel!
    @IBOutlet weak var onOffSwitch: OnOffSwitch!
    @IBOutlet weak var vStack: UIStackView!
    @IBOutlet weak var hStack: UIStackView!
    @IBOutlet weak var group1: UIView!
    @IBOutlet weak var group2: UIView!

    private var selectSegmentAction: ((Int) -> Void)?
    private var textChangeHandler: ((String)->Void)?
    private var switchAction: ((Bool)->Void)?
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        configureUI()
    }
}

extension SegmentWithTextAndSwitchCell {
    
    @objc func switchAction(_ sender: UISwitch) {
        switchAction?(sender.isOn)
    }

    @objc func segmentAction(_ sender: UISegmentedControl) {
        
        UIView.animate(withDuration: 0.15) { [weak self] in
            guard let self = self else { return }
            self.group1.alpha = sender.selectedSegmentIndex == 2 ? 0 : 1
            self.group2.alpha = sender.selectedSegmentIndex == 2 ? 0 : 1
        }
        selectSegmentAction?(sender.selectedSegmentIndex)
    }
}

extension SegmentWithTextAndSwitchCell: UITextFieldDelegate {

    func textFieldDidChangeSelection(_ textField: UITextField) {

        textChangeHandler?(textField.text ?? "")
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}

private extension SegmentWithTextAndSwitchCell {
    
    func configureUI() {
        
        bottomSeparatorView.isHidden = true
                
        titleLabel.font = Theme.font.body
        titleLabel.textColor = Theme.colour.labelPrimary
        
        switchLabel.font = Theme.font.body
        switchLabel.textColor = Theme.colour.labelPrimary
        
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
}

extension SegmentWithTextAndSwitchCell {

    func update(
        with viewModel: MnemonicNewViewModel.SegmentWithTextAndSwitchInput,
        selectSegmentAction: ((Int) -> Void)?,
        textChangeHandler: ((String)->Void)?,
        switchHandler: ((Bool)->Void)?
    ) -> SegmentWithTextAndSwitchCell {
        
        print("[AA] errorMessage: \(viewModel.errorMessage ?? "all good")")

        return update(
            title: viewModel.title ,
            password: viewModel.password ,
            placeholder: viewModel.placeholder ,
            onOffTitle: viewModel.onOffTitle ,
            onOff: viewModel.onOff ,
            segmentOptions: viewModel.segmentOptions ,
            selectedSegment: viewModel.selectedSegment ,
            selectSegmentAction: selectSegmentAction,
            textChangeHandler: textChangeHandler,
            switchHandler: switchHandler
        )
    }

    func update(
        with viewModel: MnemonicUpdateViewModel.SegmentWithTextAndSwitchInput,
        selectSegmentAction: ((Int) -> Void)?,
        textChangeHandler: ((String)->Void)?,
        switchHandler: ((Bool)->Void)?
    ) -> SegmentWithTextAndSwitchCell {
        update(
            title: viewModel.title ,
            password: viewModel.password ,
            placeholder: viewModel.placeholder ,
            onOffTitle: viewModel.onOffTitle ,
            onOff: viewModel.onOff ,
            segmentOptions: viewModel.segmentOptions ,
            selectedSegment: viewModel.selectedSegment ,
            selectSegmentAction: selectSegmentAction,
            textChangeHandler: textChangeHandler,
            switchHandler: switchHandler
        )
    }

    func update(
        with viewModel: MnemonicImportViewModel.SegmentWithTextAndSwitchInput,
        selectSegmentAction: ((Int) -> Void)?,
        textChangeHandler: ((String)->Void)?,
        switchHandler: ((Bool)->Void)?
    ) -> SegmentWithTextAndSwitchCell {
        update(
            title: viewModel.title ,
            password: viewModel.password ,
            placeholder: viewModel.placeholder ,
            onOffTitle: viewModel.onOffTitle ,
            onOff: viewModel.onOff ,
            segmentOptions: viewModel.segmentOptions ,
            selectedSegment: viewModel.selectedSegment ,
            selectSegmentAction: selectSegmentAction,
            textChangeHandler: textChangeHandler,
            switchHandler: switchHandler
        )
    }
}

private extension SegmentWithTextAndSwitchCell {

    func update(
        title: String,
        password: String,
        placeholder: String,
        onOffTitle: String,
        onOff: Bool,
        segmentOptions: [String],
        selectedSegment: Int,
        selectSegmentAction: ((Int) -> Void)?,
        textChangeHandler: ((String)->Void)?,
        switchHandler: ((Bool)->Void)?
    ) -> Self {
        titleLabel.text = title
        textField.text = password
        textField.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [
                NSAttributedString.Key.font: Theme.font.body,
                NSAttributedString.Key.foregroundColor: Theme.colour.textFieldPlaceholderColour
            ]
        )

        switchLabel.text = onOffTitle
        onOffSwitch.setOn(onOff, animated: false)

        self.selectSegmentAction = selectSegmentAction
        self.textChangeHandler = textChangeHandler
        self.switchAction = switchHandler

        for (idx, item) in segmentOptions.enumerated() {
            if segmentControl.numberOfSegments <= idx {
                segmentControl.insertSegment(withTitle: item, at: idx, animated: false)
            } else {
                segmentControl.setTitle(item, forSegmentAt: idx)
            }
        }

        segmentControl.selectedSegmentIndex = selectedSegment
        group1.alpha = segmentControl.selectedSegmentIndex == 2 ? 0 : 1
        group2.alpha = segmentControl.selectedSegmentIndex == 2 ? 0 : 1
        
        return self
    }
}
