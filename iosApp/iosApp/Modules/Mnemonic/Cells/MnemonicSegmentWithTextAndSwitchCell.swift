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
    @IBOutlet weak var separator1: UIView!
    @IBOutlet weak var group1: UIView!
    @IBOutlet weak var separator2: UIView!
    @IBOutlet weak var group2: UIView!

    var selectSegmentAction: ((Int) -> Void)?
    var textChangeHandler: ((String)->Void)?
    var switchAction: ((Bool)->Void)?

    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        configureUI()
    }

    func configureUI() {
        
        bottomSeparatorView.isHidden = true
        
        separator1.backgroundColor = Theme.colour.labelTertiary
        separator2.backgroundColor = Theme.colour.labelTertiary
        
        titleLabel.font = Theme.font.body
        titleLabel.textColor = Theme.colour.labelPrimary
        
        switchLabel.font = Theme.font.body
        switchLabel.textColor = Theme.colour.labelPrimary
        
        textField.font = Theme.font.body
        textField.textColor = Theme.colour.labelPrimary
        textField.delegate = self
        textField.rightView = makeClearButton()
        textField.rightViewMode = .whileEditing
        
        onOffSwitch.addTarget(
            self,
            action: #selector(switchAction(_:)),
            for: .valueChanged
        )
        
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

        segmentControl.setBackgroundImage(
            Theme.colour.labelQuaternary.image(),
            for: .normal,
            barMetrics: .default
        )
        segmentControl.setBackgroundImage(
            Theme.colour.labelSecondary.image(),
            for: .selected,
            barMetrics: .default
        )
        segmentControl.setDividerImage(
            UIColor.clear.image(),
            forLeftSegmentState: .normal,
            rightSegmentState: .normal,
            barMetrics: .default
        )
    }

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
        textField.attributedPlaceholder = NSAttributedString(
            string: viewModel.placeholder,
            attributes: [
                NSAttributedString.Key.font: Theme.font.body,
                NSAttributedString.Key.foregroundColor: Theme.colour.labelSecondary
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

        segmentControl.selectedSegmentIndex = viewModel.selectedSegment
        group1.alpha = segmentControl.selectedSegmentIndex == 2 ? 0 : 1
        group2.alpha = segmentControl.selectedSegmentIndex == 2 ? 0 : 1

        return self
    }
}

private extension MnemonicSegmentWithTextAndSwitchCell {
    
    func makeClearButton() -> UIButton {
        
        let button = UIButton(type: .system)
        button.setImage(
            .init(systemName: "xmark.circle.fill"),
            for: .normal
        )
        button.tintColor = Theme.colour.labelSecondary
        button.addTarget(self, action: #selector(clearTapped), for: .touchUpInside)
        return button
    }
    
    @objc func clearTapped() {
        
        textField.text = nil
    }
}

extension UIColor {
    
    func image(_ size: CGSize = CGSize(width: 1, height: 32)) -> UIImage {
        
        UIGraphicsImageRenderer(size: size).image { rendererContext in
            self.setFill()
            rendererContext.fill(CGRect(origin: .zero, size: size))
        }
    }
}
