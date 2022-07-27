// Created by web3d4v on 20/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

final class ConfirmationSwapView: UIView {
    
    private let viewModel: ConfirmationViewModel.SwapViewModel
    private let onConfirmHandler: () -> Void
    
    init(
        viewModel: ConfirmationViewModel.SwapViewModel,
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

private extension ConfirmationSwapView {
    
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
            makeTokenGroup(with: viewModel.tokenFrom),
            makeArrowDown(),
            makeTokenGroup(with: viewModel.tokenTo),
            makeBottomGroup(),
            makeConfirmButton()
        ]
        
        let stackView = VStackView(views)
        stackView.spacing = Theme.constant.padding.half
        stackView.setCustomSpacing(Theme.constant.padding * 0.25, after: views[0])
        stackView.setCustomSpacing(Theme.constant.padding * 0.25, after: views[1])
        stackView.setCustomSpacing(Theme.constant.padding, after: views[2])
        stackView.setCustomSpacing(Theme.constant.padding, after: views[3])

        addSubview(stackView)
                
        stackView.addConstraints(.toEdges)
    }
    
    func makeTokenGroup(
        with token: ConfirmationViewModel.SwapViewModel.Token
    ) -> UIView {
        
        let horizontalStack = HStackView(
            [
                makeTokenView(with: token.icon),
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
    
    func makeTokenView(with data: Data) -> UIView {
        
        let image = UIImageView(image: data.pngImage)
        
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
    
    func makeArrowDown() -> UIView {
        
        let imageView = UIImageView(image: .init(systemName: "arrow.down"))
        imageView.tintColor = Theme.colour.labelPrimary
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = Theme.colour.cellBackground
        backgroundView.addSubview(imageView)
        backgroundView.layer.cornerRadius = Theme.constant.cornerRadiusSmall.half
        imageView.addConstraints(
            [
                .layout(anchor: .centerXAnchor),
                .layout(anchor: .centerYAnchor),
                .layout(anchor: .heightAnchor, constant: .equalTo(constant: 16)),
                .layout(anchor: .widthAnchor, constant: .equalTo(constant: 16))
            ]
        )
        
        let view = UIView()
        view.backgroundColor = .clear
        view.addSubview(backgroundView)
        backgroundView.addConstraints(
            [
                .layout(anchor: .centerXAnchor),
                .layout(anchor: .topAnchor),
                .layout(anchor: .bottomAnchor),
                .layout(anchor: .heightAnchor, constant: .equalTo(constant: 24)),
                .layout(anchor: .widthAnchor, constant: .equalTo(constant: 24))
            ]
        )
        
        return view
    }
    
    func makeBottomGroup() -> UIView {
        
        let views = [
            makeProvider(),
            makeDividerLine(),
            makeRow(
                with: Localized("confirmation.slippage"),
                value: viewModel.provider.slippage
            ),
            makeDividerLine(),
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
    
    func makeProvider() -> UIView {
        
        let providerLabel = UILabel()
        providerLabel.apply(style: .body)
        providerLabel.text = Localized("confirmation.provider")
        
        let icon = UIImageView(image: viewModel.provider.icon.pngImage)
        
        let providerName = UILabel()
        providerName.apply(style: .body)
        providerName.text = viewModel.provider.name.capitalized

        let horizontalStack = HStackView(
            [
                providerLabel, icon, providerName
            ]
        )
        horizontalStack.spacing = Theme.constant.padding * 0.5
        
        icon.addConstraints(
            [
                .layout(anchor: .heightAnchor, constant: .equalTo(constant: 24)),
                .layout(anchor: .widthAnchor, constant: .equalTo(constant: 24))
            ]
        )
        
        return horizontalStack
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
    
    func makeDividerLine() -> UIView {
        
        let divider = UIView()
        divider.backgroundColor = Theme.colour.separatorWithTransparency
        
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
