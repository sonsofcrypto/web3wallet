// Created by web3d4v on 28/05/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

extension NFTDetailViewController {
    
    func makeMainScrollView() -> UIScrollView {
        
        let mainScrollView = UIScrollView()
        mainScrollView.showsVerticalScrollIndicator = false
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = Theme.colour.fillTertiary
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        mainScrollView.refreshControl = refreshControl
        
        let scrollableContentView = UIView()
        mainScrollView.addSubview(scrollableContentView)
        self.scrollableContentView = scrollableContentView
        scrollableContentView.addConstraints(
            [
                .layout(
                    anchor: .topAnchor,
                    constant: .equalTo(
                        constant: Global.padding
                    )
                ),
                .layout(anchor: .bottomAnchor),
                .layout(anchor: .centerXAnchor),
                .layout(anchor: .widthAnchor)
            ]
        )
        
        return mainScrollView
    }
    
    func makeSectionTextInHorizontalStack(with text: String) -> UIView {
        
        let hStack = HStackView()
        
        hStack.addArrangedSubview(.hSpace(value: Global.padding))
        
        let label = UILabel(with: .body)
        label.text = text
        label.textColor = Theme.colour.systemRed
        label.layer.applyShadow(Theme.colour.systemRed)
        label.numberOfLines = 0
        hStack.addArrangedSubview(label)

        hStack.addArrangedSubview(.hSpace(value: Global.padding))
        
        return hStack
    }
}
