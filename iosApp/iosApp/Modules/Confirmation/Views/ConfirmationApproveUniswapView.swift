// Created by web3d4v on 03/09/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import SwiftUI

final class ConfirmationApproveUniswapView: UIView {
    private let viewModel: ConfirmationViewModel.ApproveUniswapViewModel
    private let onConfirmHandler: () -> Void
    
    init(
        viewModel: ConfirmationViewModel.ApproveUniswapViewModel,
        onConfirmHandler: @escaping () -> Void
    ) {
        self.viewModel = viewModel
        self.onConfirmHandler = onConfirmHandler
        super.init(frame: .zero)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension ConfirmationApproveUniswapView {
    
    func configureUI() {
        let views: [UIView] = [
            tokenView(with: viewModel.iconName),
            infoGroup(),
            estimatedFeesGroup(),
            confirmButton()
        ]
        let stackView = VStackView(views)
        stackView.spacing = Theme.constant.padding.half
        stackView.setCustomSpacing(Theme.constant.padding, after: views[0])
        stackView.setCustomSpacing(Theme.constant.padding, after: views[1])
        stackView.setCustomSpacing(Theme.constant.padding, after: views[2])
        addSubview(stackView)
        stackView.addConstraints(.toEdges)
    }
    
    func infoGroup() -> UIView {
        let verticalStack = VStackView(
            [title(), body()]
        )
        verticalStack.spacing = Theme.constant.padding
        return verticalStack
    }
    
    func tokenView(with iconName: String) -> UIView {
        let image = UIImageView(image: iconName.assetImage)
        image.layer.cornerRadius = 20
        image.clipsToBounds = true
        let view = UIView()
        view.backgroundColor = .clear
        view.addSubview(image)
        image.addConstraints(
            [
                .layout(anchor: .widthAnchor, constant: .equalTo(constant: 40)),
                .layout(anchor: .heightAnchor, constant: .equalTo(constant: 40)),
                .layout(anchor: .centerXAnchor),
                .layout(anchor: .topAnchor),
                .layout(anchor: .bottomAnchor)
            ]
        )
        return view
    }
    
    func title() -> UILabel {
        let label = UILabel()
        label.apply(style: .title3)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.text = Localized("confirmation.approveUniswap.permission.title", viewModel.symbol)
        return label
    }

    func body() -> UILabel {
        let label = UILabel()
        label.apply(style: .subheadline)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.text = Localized("confirmation.approveUniswap.permission.message", viewModel.symbol)
        return label
    }
    
    func estimatedFeesGroup() -> UIView {
        let views = [
            row(
                with: Localized("confirmation.estimatedFee"),
                value: viewModel.fee.usdValue
            )
        ]
        let stack = VStackView(views)
        stack.spacing = Theme.constant.padding * 0.5
        let view = UIView()
        view.layer.cornerRadius = Theme.constant.cornerRadius
        view.backgroundColor = Theme.colour.cellBackground
        view.addSubview(stack)
        stack.addConstraints(
            .toEdges(padding: Theme.constant.padding)
        )
        return view
    }
    
    func row(with name: String, value: String) -> UIView {
        let titleLabel = UILabel()
        titleLabel.apply(style: .body)
        titleLabel.text = name
        let valueLabel = UILabel()
        valueLabel.apply(style: .body)
        valueLabel.textAlignment = .right
        valueLabel.text = value
        let horizontalStack = HStackView(
            [
                titleLabel, valueLabel
            ]
        )
        titleLabel.addConstraints(
            [
                .layout(anchor: .heightAnchor, constant: .equalTo(constant: 24))
            ]
        )
        return horizontalStack
    }
    
    func confirmButton() -> UIButton {
        let button = Button()
        button.style = .primary
        button.setTitle(Localized("confirmation.approveUniswap.confirm"), for: .normal)
        button.addTarget(self, action: #selector(confirmTapped), for: .touchUpInside)
        return button
    }
    
    @objc func confirmTapped() {
        onConfirmHandler()
    }
}
