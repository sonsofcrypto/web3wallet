// Created by web3d4v on 10/08/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

final class ConfirmationTxSuccessView: UIView {
    
    private let viewModel: ConfirmationViewModel.TxSuccessViewModel
    private let handler: Handler
    
    struct Handler {
        
        let onCTATapped: () -> Void
    }
    
    init(
        viewModel: ConfirmationViewModel.TxSuccessViewModel,
        handler: Handler
    ) {
        
        self.viewModel = viewModel
        self.handler = handler
        
        super.init(frame: .zero)
        
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension ConfirmationTxSuccessView {
    
    func configureUI() {
        
        let views: [UIView] = [
            makeOnSuccessView(),
            makeLabel(with: .body, and: viewModel.title),
            makeLabel(with: .footnote, and: viewModel.message)
        ]
        
        let stackView = VStackView(views)
        stackView.spacing = Theme.constant.padding
        stackView.setCustomSpacing(Theme.constant.padding, after: views[0])
        stackView.setCustomSpacing(Theme.constant.padding, after: views[1])

        let wrapperView = UIView()
        wrapperView.backgroundColor = .clear
        wrapperView.tag = 12

        wrapperView.addSubview(stackView)
        stackView.addConstraints(
            [
                .layout(anchor: .leadingAnchor, constant: .equalTo(constant: Theme.constant.padding)),
                .layout(anchor: .trailingAnchor, constant: .equalTo(constant: Theme.constant.padding)),
                .layout(anchor: .centerYAnchor, constant: .equalTo(constant: (Theme.constant.padding + 40).half))
            ]
        )

        addSubview(wrapperView)
        
        wrapperView.addConstraints(.toEdges)
        
        let cta = makeCTAButton()
        addSubview(cta)
        cta.addConstraints(
            [
                .layout(anchor: .leadingAnchor, constant: .equalTo(constant: Theme.constant.padding)),
                .layout(anchor: .trailingAnchor, constant: .equalTo(constant: Theme.constant.padding)),
                .layout(anchor: .bottomAnchor, constant: .equalTo(constant: Theme.constant.padding))
            ]
        )
    }
    
    func makeOnSuccessView() -> UIView {
        
        let image = UIImage(systemName: "checkmark.circle.fill")
        let config = UIImage.SymbolConfiguration(
            paletteColors: [
                Theme.colour.labelPrimary,
                Theme.colour.candleGreen
            ]
        )
        let imageView = UIImageView(image: image?.applyingSymbolConfiguration(config))
        imageView.addConstraints(
            [
                .layout(anchor: .widthAnchor, constant: .equalTo(constant: 60)),
                .layout(anchor: .heightAnchor, constant: .equalTo(constant: 60))
            ]
        )

        let wrapperView = UIView()
        wrapperView.backgroundColor = .clear
        wrapperView.addSubview(imageView)
        
        imageView.addConstraints(
            [
                .layout(anchor: .topAnchor),
                .layout(anchor: .bottomAnchor),
                .layout(anchor: .centerXAnchor)
            ]
        )
            
        return wrapperView
    }
    
    func makeLabel(
        with style: UILabel.Style,
        and text: String
    ) -> UIView {
        
        let label = UILabel()
        label.apply(style: style)
        label.text = text
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }
    
    func makeCTAButton() -> Button {
        
        let button = Button()
        button.style = .primary
        button.setTitle(viewModel.cta, for: .normal)
        button.addTarget(self, action: #selector(onCTATapped), for: .touchUpInside)
        return button
    }
    
    @objc func onCTATapped() {
        
        handler.onCTATapped()
    }
}
