// Created by web3d3v on 13/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

final class SwapInputView: UIView {

    let textField = UITextField()
    let fiatValueLabel = UILabel(with: .caption2)
    let currencyButton = LeftRightImageButton()
    let balanceLabel = UILabel(with: .caption2)

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = Theme.colour.backgroundBaseSecondary
        layer.cornerRadius = Theme.constant.cornerRadiusSmall
        layer.masksToBounds = true

        textField.textColor = Theme.colour.labelPrimary
        textField.font = Theme.font.title1
        textField.keyboardType = .decimalPad

        currencyButton.rightImageView.image = UIImage(named: "chevron_down")
        currencyButton.titleLabel?.apply(style: .callout)
        currencyButton.titleLabel?.layer.shadowOpacity = 0
        currencyButton.titleLabel?.textAlignment = .center

        [fiatValueLabel, balanceLabel].forEach {
            $0.textColor = Theme.colour.labelSecondary
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
        currencyStack.spacing = Theme.constant.padding / 2

        addSubview(container)

        addConstraints([
            container.topAnchor.constraint(equalTo: topAnchor, constant: Theme.constant.padding),
            container.leftAnchor.constraint(equalTo: leftAnchor, constant: Theme.constant.padding),
            container.rightAnchor.constraint(equalTo: rightAnchor, constant: -Theme.constant.padding),
            container.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Theme.constant.padding),
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
