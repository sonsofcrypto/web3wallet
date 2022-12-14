// Created by web3d4v on 10/08/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

final class ConfirmationTxSuccessView: UIView {
    private let viewModel: ConfirmationTxSuccessViewModel
    private let handler: Handler
    
    struct Handler {
        let onCTATapped: () -> Void
        let onCTASecondaryTapped: () -> Void
    }
    
    init(
        viewModel: ConfirmationTxSuccessViewModel,
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
            successView(),
            viewEtherScanButton(),
            ctaButton()
        ]
        let stackView = VStackView(views)
        stackView.spacing = Theme.padding
        let wrapperView = UIView()
        wrapperView.backgroundColor = .clear
        wrapperView.tag = 12
        wrapperView.addSubview(stackView)
        stackView.addConstraints(.toEdges)
        addSubview(wrapperView)
        wrapperView.addConstraints(.toEdges)
    }
    
    func successView() -> UIView {
        let views: [UIView] = [
            onSuccessView(),
            label(with: .title3, and: viewModel.title),
            label(with: .body, and: viewModel.message),
        ]
        let stackView = VStackView(views)
        stackView.spacing = Theme.padding
        let wrapperView = UIView()
        wrapperView.backgroundColor = .clear
        wrapperView.tag = 12
        wrapperView.addSubview(stackView)
        stackView.addConstraints(
            [
                .layout(anchor: .leadingAnchor),
                .layout(anchor: .trailingAnchor),
                .layout(anchor: .centerYAnchor)
            ]
        )
        return wrapperView
    }
    
    func onSuccessView() -> UIView {
        let image = UIImage(systemName: "checkmark.circle.fill")
        let config = UIImage.SymbolConfiguration(
            paletteColors: [
                Theme.color.textPrimary,
                Theme.color.priceUp
            ]
        )
        let imageView = UIImageView(image: image?.applyingSymbolConfiguration(config))
        imageView.contentMode = .scaleAspectFit
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
    
    func label(
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
    
    func ctaButton() -> Button {
        let button = Button()
        button.style = .primary
        button.setTitle(viewModel.cta, for: .normal)
        button.addTarget(self, action: #selector(onCTATapped), for: .touchUpInside)
        return button
    }
    
    func viewEtherScanButton() -> Button {
        let button = Button()
        button.style = .secondary
        button.setTitle(viewModel.ctaSecondary, for: .normal)
        button.addTarget(self, action: #selector(onCTASecondaryTapped), for: .touchUpInside)
        return button
    }
    
    @objc func onCTATapped() {
        handler.onCTATapped()
    }
    
    @objc func onCTASecondaryTapped() {
        handler.onCTASecondaryTapped()
    }
}
