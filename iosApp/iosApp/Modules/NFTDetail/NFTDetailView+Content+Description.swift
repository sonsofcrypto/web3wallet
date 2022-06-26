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
        
        view.layer.cornerRadius = Global.cornerRadius
        view.layer.borderWidth = 1
        view.layer.borderColor = ThemeOG.color.tintLight.cgColor

        return view
    }
}

private extension NFTDetailViewController {
    
    func makeDescriptionContent(with description: String) -> UIView {
        
        let vStack = VStackView()
        
        vStack.addArrangedSubview(.vSpace(height: Global.padding))
        
        let sectionTitle = makeSectionTextInHorizontalStack(
            with: Localized("nft.detail.section.title.description")
        )
        vStack.addArrangedSubview(sectionTitle)
        
        vStack.addArrangedSubview(.vSpace(height: Global.padding))
        vStack.addArrangedSubview(
            .dividerLine(backgroundColor: ThemeOG.color.tintLight)
        )
        vStack.addArrangedSubview(.vSpace(height: Global.padding))
        
        let sectionContent = makeTextInHorizontalStack(with: description)
        vStack.addArrangedSubview(sectionContent)

        vStack.addArrangedSubview(.vSpace(height: Global.padding))
                
        return vStack
    }
    
    func makeTextInHorizontalStack(with text: String) -> UIView {
        
        let hStack = HStackView()
        
        hStack.addArrangedSubview(.hSpace(value: Global.padding))
        
        let label = UILabel()
        label.text = text
        label.textColor = ThemeOG.color.text
        label.numberOfLines = 0
        label.applyStyle(.body)
        hStack.addArrangedSubview(label)

        hStack.addArrangedSubview(.hSpace(value: Global.padding))
        
        return hStack
    }
}
