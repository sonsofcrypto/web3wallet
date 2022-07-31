// Created by web3d4v on 21/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

final class ConfirmationSendView: UIView {
    
    private let viewModel: ConfirmationViewModel.SendViewModel
    private let onConfirmHandler: () -> Void
    
    init(
        viewModel: ConfirmationViewModel.SendViewModel,
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

private extension ConfirmationSendView {
    
    func configureUI() {
        
//        let providerLogo = UIImageView(
//            image: .init(named: "\(viewModel.provider.name)-logo-overlay")
//        )
//        addSubview(providerLogo)
//        providerLogo.addConstraints(
//            [
//                .layout(anchor: .centerXAnchor),
//                .layout(anchor: .topAnchor, constant: .equalTo(constant: Theme.constant.padding)),
//                .layout(anchor: .widthAnchor, constant: .equalTo(constant: 168)),
//                .layout(anchor: .heightAnchor, constant: .equalTo(constant: 194))
//            ]
//        )
        
        let views: [UIView] = [
            makeTokenGroup(with: viewModel.token),
            makeDestinationGroup(),
            makeEstimatedFeesGroup(),
            makeConfirmButton()
        ]
        
        let stackView = VStackView(views)
        stackView.spacing = Theme.constant.padding.half
        stackView.setCustomSpacing(Theme.constant.padding, after: views[0])
        stackView.setCustomSpacing(Theme.constant.padding, after: views[1])
        stackView.setCustomSpacing(Theme.constant.padding, after: views[2])

        addSubview(stackView)
                
        stackView.addConstraints(.toEdges)
    }
    
    func makeTokenGroup(
        with token: ConfirmationViewModel.SendViewModel.Token
    ) -> UIView {
        
        let horizontalStack = HStackView(
            [
                makeTokenView(with: token.iconName),
                makeTokenAmountView(with: token.value, and: token.usdValue)
            ]
        )
        horizontalStack.spacing = Theme.constant.padding
        
        let view = UIView()
        view.layer.cornerRadius = Theme.constant.cornerRadius
        view.backgroundColor = Theme.colour.cellBackground
        view.addSubview(horizontalStack)
        
        horizontalStack.addConstraints(
            .toEdges(padding: Theme.constant.padding)
        )
        
        return view
    }
    
    func makeTokenView(with iconName: String) -> UIView {
        
        let image = UIImageView(image: iconName.assetImage)
        
        let view = UIView()
        view.backgroundColor = .clear
        view.addSubview(image)
        
        image.addConstraints(
            [
                .layout(anchor: .widthAnchor, constant: .equalTo(constant: 32)),
                .layout(anchor: .heightAnchor, constant: .equalTo(constant: 32)),
                .layout(anchor: .leadingAnchor),
                .layout(anchor: .trailingAnchor),
                .layout(anchor: .centerYAnchor),
            ]
        )
        
        return view
    }
    
    func makeTokenAmountView(
        with value: String,
        and usdValue: String
    ) -> UIView {
        
        let amountLabel = UILabel()
        amountLabel.apply(style: .title3)
        amountLabel.text = value
                
        let amountUSDLabel = UILabel()
        amountUSDLabel.apply(style: .footnote)
        amountUSDLabel.text = usdValue
        
        let stackView = VStackView([amountLabel, amountUSDLabel])
        stackView.spacing = Theme.constant.padding * 0.25
        return stackView
    }
    
    func makeDestinationGroup() -> UIView {
        
        let views = [
            makeRow(
                with: Localized("confirmation.from"),
                value: viewModel.destination.from
            ),
            makeDividerLine(),
            makeRow(
                with: Localized("confirmation.to"),
                value: viewModel.destination.to
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
    
    func makeDividerLine() -> UIView {
        
        let divider = UIView()
        divider.backgroundColor = Theme.colour.separatorTransparent
        
        let view = UIView()
        view.backgroundColor = .clear
        view.addSubview(divider)
        
        divider.addConstraints(
            [
                .layout(anchor: .leadingAnchor),
                .layout(anchor: .trailingAnchor, constant: .equalTo(constant: -Theme.constant.padding)),
                .layout(anchor: .heightAnchor, constant: .equalTo(constant: 1)),
                .layout(anchor: .topAnchor),
                .layout(anchor: .bottomAnchor)
                
            ]
        )
        
        return view
    }
    
    func makeEstimatedFeesGroup() -> UIView {
        
        let views = [
            makeRow(
                with: Localized("confirmation.estimatedFee"),
                value: viewModel.estimatedFee.usdValue
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
    
    func makeRow(with name: String, value: String) -> UIView {
        
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
    
    func makeConfirmButton() -> UIButton {
        
        let button = Button()
        button.style = .primary
        button.setTitle(Localized("confirmation.swap.confirm"), for: .normal)
        button.addTarget(self, action: #selector(confirmTapped), for: .touchUpInside)
        return button
    }
    
    @objc func confirmTapped() {
        
        onConfirmHandler()
    }
}
