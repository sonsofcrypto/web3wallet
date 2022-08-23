// Created by web3d4v on 21/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

final class ConfirmationCultCastVoteView: UIView {
    
    private let viewModel: ConfirmationViewModel.CultCastVoteViewModel
    private let onConfirmHandler: () -> Void
    
    init(
        viewModel: ConfirmationViewModel.CultCastVoteViewModel,
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

private extension ConfirmationCultCastVoteView {
    
    func configureUI() {
        
        let emptyView = UIView()
        emptyView.backgroundColor = .clear
        let views: [UIView] = [
            makeCultLogo(),
            makeAction(),
            makeTitle(),
            emptyView,
            makeConfirmButton()
        ]
        
        let stackView = VStackView(views)
        stackView.spacing = Theme.constant.padding

        addSubview(stackView)
                
        stackView.addConstraints(.toEdges)
    }
    
    func makeAction() -> UIView {
        
        let label = UILabel()
        label.apply(style: .title3)
        label.text = viewModel.action
        label.textAlignment = .center
        return label
    }

    func makeTitle() -> UIView {
        
        let label = UILabel()
        label.apply(style: .body)
        label.text = viewModel.name
        label.textAlignment = .center
        label.numberOfLines = 3
        return label
    }
    
    func makeCultLogo() -> UIView {
        
        let image = UIImageView()
        image.image = "cult-dao-big-icon".assetImage
        image.contentMode = .scaleAspectFit

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
    
    func makeConfirmButton() -> UIButton {
        
        let button = Button()
        button.style = .primary
        button.setTitle(Localized("confirmation.cultCastVote.confirm"), for: .normal)
        button.addTarget(self, action: #selector(confirmTapped), for: .touchUpInside)
        return button
    }
    
    @objc func confirmTapped() {
        
        onConfirmHandler()
    }
}
