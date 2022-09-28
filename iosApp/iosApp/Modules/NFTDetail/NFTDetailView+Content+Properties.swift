// Created by web3d4v on 29/05/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

extension NFTDetailViewController {
    
    func makeProperties(with item: NFTItem) -> [UIView] {
        guard !item.properties.isEmpty else { return [] }
        let view = UIView()
        view.backgroundColor = .clear
        let content = makePropertiesContent(with: item.properties)
        view.addSubview(content)
        content.addConstraints(.toEdges(padding: Theme.constant.padding))
        view.layer.cornerRadius = Theme.constant.cornerRadius
        view.backgroundColor = Theme.colour.cellBackground
        return [view]
    }
}

private extension NFTDetailViewController {
    
    func makePropertiesContent(with properties: [NFTItem.Property]) -> UIView {
        var rows: [UIView] = []
        let titleLabel = UILabel()
        titleLabel.apply(style: .headline, weight: .bold)
        titleLabel.text = Localized("nft.detail.section.title.properties")
        titleLabel.numberOfLines = 0
        rows.append(titleLabel)
        rows.append(.dividerLine())
        properties.forEach {
            let propertyName = UILabel()
            propertyName.numberOfLines = 1
            propertyName.apply(style: .subheadline)
            propertyName.textColor = Theme.colour.labelSecondary
            propertyName.textAlignment = .left
            propertyName.text = $0.name
            let propertyValue = UILabel()
            propertyValue.numberOfLines = 1
            propertyValue.apply(style: .subheadline, weight: .bold)
            propertyValue.textAlignment = .left
            propertyValue.text = $0.value
            let hStack = HStackView([propertyName, propertyValue])
            hStack.spacing = Theme.constant.padding.half
            propertyName.setContentHuggingPriority(.required, for: .horizontal)
            rows.append(hStack)
        }
        let vStack = VStackView(rows)
        vStack.spacing = Theme.constant.padding.half
        return vStack
    }
}
