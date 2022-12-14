// Created by web3d4v on 10/08/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

final class ConfirmationTxInProgressView: UIView {
    private let viewModel: ConfirmationTxInProgressViewModel
    
    init(viewModel: ConfirmationTxInProgressViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension ConfirmationTxInProgressView {
    
    func configureUI() {
        let views: [UIView] = [
            animationView(),
            label(with: .title3, and: viewModel.title),
            label(with: .body, and: viewModel.message)
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
                .layout(anchor: .leadingAnchor),
                .layout(anchor: .trailingAnchor),
                .layout(anchor: .centerYAnchor, constant: .equalTo(constant: Theme.constant.padding * 2))
            ]
        )
        addSubview(wrapperView)
        wrapperView.addConstraints(.toEdges)
    }
    
    func animationView() -> UIView {
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = Theme.color.activityIndicator
        activityIndicator.startAnimating()
        let view = UIView()
        view.backgroundColor = Theme.color.bgPrimary
        view.layer.cornerRadius = Theme.constant.cornerRadiusSmall
        view.addConstraints(
            [
                .layout(anchor: .widthAnchor, constant: .equalTo(constant: 80)),
                .layout(anchor: .heightAnchor, constant: .equalTo(constant: 80))
            ]
        )
        view.addSubview(activityIndicator)
        activityIndicator.addConstraints(
            [
                .layout(anchor: .centerXAnchor),
                .layout(anchor: .centerYAnchor)
            ]
        )
        let wrapperView = UIView()
        wrapperView.backgroundColor = .clear
        wrapperView.addSubview(view)
        view.addConstraints(
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
}
