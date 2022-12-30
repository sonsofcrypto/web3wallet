// Created by web3d3v on 13/04/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

final class SegmentWithTextAndSwitchCell: CollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var segmentControl: SegmentedControl!
    @IBOutlet weak var textField: TextField!
    @IBOutlet weak var hintLabel: UILabel!
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
        
        // NOTE: Not ideal to assume here that Pin is segement at index 0 but works for now
        if sender.selectedSegmentIndex == 0 {
            textField.keyboardType = .phonePad
        } else {
            textField.keyboardType = .default
        }
        
        textField.resignFirstResponder()
        if sender.selectedSegmentIndex != 2 {
            textField.becomeFirstResponder()
        }
        
        textField.text = nil
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
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//            [weak self] in
//            guard let self = self else { return }
//            self.textChangeHandler?(textField.text ?? "")
//        }
        // NOTE: Doing this since this will trigger the collection view to scroll to
        // the last visible item
        //textChangeHandler?(textField.text ?? "")
    }
}

private extension SegmentWithTextAndSwitchCell {
    
    func configureUI() {
        
        bottomSeparatorView.isHidden = true
                
        titleLabel.font = Theme.font.body
        titleLabel.textColor = Theme.color.textPrimary
        
        switchLabel.font = Theme.font.body
        switchLabel.textColor = Theme.color.textPrimary
        
        textField.delegate = self
        textField.keyboardType = .numberPad
        textField.returnKeyType = .done
        textField.addDoneInputAccessoryView(
            with: .targetAction(.init(target: self, selector: #selector(dismissKeyboard)))
        )

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
        
        hintLabel.apply(style: .caption2)
        hintLabel.textColor = Theme.color.textPrimary
    }
}

extension SegmentWithTextAndSwitchCell {

    func update(
        with viewModel: SegmentWithTextAndSwitchCellViewModel,
        selectSegmentAction: ((Int) -> Void)?,
        textChangeHandler: ((String)->Void)?,
        switchHandler: ((Bool)->Void)?
    ) -> SegmentWithTextAndSwitchCell {
                
        titleLabel.text = viewModel.title
        textField.text = viewModel.password
        textField.attributedPlaceholder = NSAttributedString(
            string: viewModel.placeholder,
            attributes: [
                NSAttributedString.Key.font: Theme.font.body,
                NSAttributedString.Key.foregroundColor: Theme.color.textSecondary
            ]
        )

        switchLabel.text = viewModel.onOffTitle
        onOffSwitch.setOn(viewModel.onOff, animated: false)

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

        segmentControl.selectedSegmentIndex = viewModel.selectedSegment.int
        group1.alpha = segmentControl.selectedSegmentIndex == 2 ? 0 : 1
        group2.alpha = segmentControl.selectedSegmentIndex == 2 ? 0 : 1
        updateHintLabel(with: viewModel.errorMessage)
        
        return self
    }
}

private extension SegmentWithTextAndSwitchCell {
    
    @objc func dismissKeyboard() {
        
        textField.resignFirstResponder()
    }
    
    func updateHintLabel(with text: String?) {
        
        hintLabel.text = text
        DispatchQueue.main.async { [weak self] in
            self?.hintLabel.isHidden = text == nil
        }

    }
}
