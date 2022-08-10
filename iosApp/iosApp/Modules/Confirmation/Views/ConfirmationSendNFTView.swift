// Created by web3d4v on 21/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

final class ConfirmationSendNFTView: UIView {
    
    private let viewModel: ConfirmationViewModel.SendNFTViewModel
    private let onConfirmHandler: () -> Void
    
    init(
        viewModel: ConfirmationViewModel.SendNFTViewModel,
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

private extension ConfirmationSendNFTView {
    
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
            makeImageView(with: viewModel.nftItem),
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
    
    func makeImageView(with nftItem: NFTItem) -> UIView {
        
        let image = UIImageView()
        image.load(url: nftItem.image)
        image.layer.cornerRadius = Theme.constant.cornerRadiusSmall
        image.clipsToBounds = true

        let view = UIView()
        view.backgroundColor = .clear
        view.addSubview(image)
        
        image.addConstraints(
            [
                .layout(anchor: .widthAnchor, constant: .equalTo(constant: 100)),
                .layout(anchor: .heightAnchor, constant: .equalTo(constant: 100)),
                .layout(anchor: .topAnchor),
                .layout(anchor: .bottomAnchor),
                .layout(anchor: .centerXAnchor),
            ]
        )
        
        return view
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
        button.setTitle(Localized("confirmation.sendNFT.confirm"), for: .normal)
        button.addTarget(self, action: #selector(confirmTapped), for: .touchUpInside)
        return button
    }
    
    @objc func confirmTapped() {
        
        onConfirmHandler()
    }
}
