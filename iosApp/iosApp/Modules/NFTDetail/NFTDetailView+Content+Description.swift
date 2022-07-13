// Created by web3d4v on 27/05/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

extension NFTDetailViewController {
    
    func makeDescription(with item: NFTCollection) -> UIView {
        
        let view = UIView()
        view.backgroundColor = .clear
            
        let content = makeDescriptionContent(with: item.description)
        view.addSubview(content)
        content.addConstraints(.toEdges)
        
        view.layer.cornerRadius = Theme.constant.cornerRadiusSmall
        view.layer.borderWidth = 1
        view.layer.borderColor = Theme.colour.fillTertiary.cgColor

        return view
    }
}

private extension NFTDetailViewController {
    
    func makeDescriptionContent(with description: String) -> UIView {
        
        let vStack = VStackView()
        
        vStack.addArrangedSubview(.vSpace(height: Theme.constant.padding))
        
        let sectionTitle = makeSectionTextInHorizontalStack(
            with: Localized("nft.detail.section.title.description")
        )
        vStack.addArrangedSubview(sectionTitle)
        
        vStack.addArrangedSubview(.vSpace(height: Theme.constant.padding))
        vStack.addArrangedSubview(
            .dividerLine(backgroundColor: Theme.colour.fillTertiary)
        )
        vStack.addArrangedSubview(.vSpace(height: Theme.constant.padding))
        
        let sectionContent = makeTextInHorizontalStack(with: description)
        vStack.addArrangedSubview(sectionContent)

        vStack.addArrangedSubview(.vSpace(height: Theme.constant.padding))
                
        return vStack
    }
    
    func makeTextInHorizontalStack(with text: String) -> UIView {
        
        let hStack = HStackView()
        
        hStack.addArrangedSubview(.hSpace(value: Theme.constant.padding))
        
        let label = UILabel()
        label.text = text
        label.textColor = Theme.colour.labelPrimary
        label.numberOfLines = 0
        label.apply(style: .body)
        hStack.addArrangedSubview(label)

        hStack.addArrangedSubview(.hSpace(value: Theme.constant.padding))
        
        return hStack
    }
}
