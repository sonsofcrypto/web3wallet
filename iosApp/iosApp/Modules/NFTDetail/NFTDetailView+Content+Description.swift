// Created by web3d4v on 27/05/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import web3walletcore

extension NFTDetailViewController {
    
    func makeDescription(with item: NFTCollection) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        let content = makeDescriptionContent(with: item.description_)
        view.addSubview(content)
        content.addConstraints(.toEdges(padding: Theme.padding))
        view.layer.cornerRadius = Theme.cornerRadius
        view.backgroundColor = Theme.color.bgPrimary
        return view
    }
}

private extension NFTDetailViewController {
    
    func makeDescriptionContent(with description: String) -> UIView {
        let vStack = VStackView()
        let sectionTitle = UILabel()
        sectionTitle.apply(style: .headline, weight: .bold)
        sectionTitle.text = Localized("nft.detail.section.title.description")
        sectionTitle.numberOfLines = 0
        vStack.addArrangedSubview(sectionTitle)
        vStack.addArrangedSubview(TransparentLineView())
        let sectionContent = UILabel()
        sectionContent.apply(style: .body)
        sectionContent.text = description
        sectionContent.numberOfLines = 0
        vStack.addArrangedSubview(sectionContent)
        vStack.spacing = Theme.padding * 0.5
        return vStack
    }
}
