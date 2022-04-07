//
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT
//

import UIKit

class SwapInputView: UIView {

    let textField = UITextField()
    let fiatValueLabel = UILabel(with: .smallestLabel)
    let currencyButton = LeftRightImageButton()
    let balanceLabel = UILabel(with: .smallestLabel)

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor.bgGradientTopSecondary
        layer.cornerRadius = Global.cornerRadius
        layer.masksToBounds = true

        textField.textColor = Theme.current.textColor
        textField.font = Theme.current.title1
        textField.keyboardType = .decimalPad

        currencyButton.rightImageView.image = UIImage(named: "chevron_down")
        currencyButton.titleLabel?.applyStyle(.smallestLabel)
        currencyButton.titleLabel?.layer.shadowOpacity = 0
        currencyButton.titleLabel?.textAlignment = .center

        [fiatValueLabel, balanceLabel].forEach {
            $0.textColor = Theme.current.textColorSecondary
        }

        [currencyButton, balanceLabel].forEach {
            $0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        }

        let inputStack = UIStackView(arrangedSubviews: [textField, fiatValueLabel])
        let currencyStack = UIStackView(arrangedSubviews: [currencyButton, balanceLabel])
        let container = UIStackView(arrangedSubviews: [inputStack, currencyStack])

        container.axis = .horizontal
        container.translatesAutoresizingMaskIntoConstraints = false
        [inputStack, currencyStack].forEach { $0.axis = .vertical }

        fiatValueLabel.setContentHuggingPriority(.required, for: .vertical)
        currencyStack.spacing = Global.padding / 2

        addSubview(container)

        addConstraints([
            container.topAnchor.constraint(equalTo: topAnchor, constant: Global.padding),
            container.leftAnchor.constraint(equalTo: leftAnchor, constant: Global.padding),
            container.rightAnchor.constraint(equalTo: rightAnchor, constant: -Global.padding),
            container.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Global.padding),
            currencyButton.heightAnchor.constraint(equalToConstant: Constant.btnHeight),
            currencyButton.widthAnchor.constraint(equalToConstant: Constant.btnWidth)
        ])

    }
}

// MARK: - SwapViewModel

extension SwapInputView {

    func update(with viewModel: SwapViewModel.Input) {
        textField.text = viewModel.valueCrypto
        fiatValueLabel.text = viewModel.valueFiat
        balanceLabel.text = Localized("balance:") + " " + viewModel.balance
        currencyButton.setTitle(viewModel.ticker, for: .normal)
        currencyButton.setImage(UIImage(named: viewModel.currencyImage), for: .normal)
    }
}

// MARK: - SwapViewModel

extension SwapInputView {

    enum Constant {
        static let btnWidth: CGFloat = 78
        static let btnHeight: CGFloat = 26
    }
}
