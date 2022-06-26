// Created by web3d4v on 29/05/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

extension NFTDetailViewController {
    
    enum PropertyLayout {
        
        case option1
        case option2
    }
    
    func makeProperties(with item: NFTItem) -> UIView? {
        
        guard !item.properties.isEmpty else { return nil }
        
        let view = UIView()
        view.backgroundColor = .clear
            
        let content = makePropertiesContent(
            with: item.properties,
            layout: .option2
        )
        view.addSubview(content)
        content.addConstraints(.toEdges)
        
        view.layer.cornerRadius = Global.cornerRadius
        view.layer.borderWidth = 1
        view.layer.borderColor = Theme.color.tintLight.cgColor

        return view
    }
}

private extension NFTDetailViewController {
    
    func makePropertiesContent(
        with properties: [NFTItem.Property],
        layout: PropertyLayout
    ) -> UIView {
        
        var rows: [UIView] = []
        
        rows.append(.vSpace(height: Global.padding))
        
        let titleLabel = makeSectionTextInHorizontalStack(
            with: Localized("nft.detail.section.title.properties")
        )
        rows.append(titleLabel)
        
        rows.append(.vSpace(height: Global.padding))
        rows.append(
            .dividerLine(backgroundColor: Theme.color.tintLight)
        )
        rows.append(.vSpace(height: Global.padding))

        switch layout {
        case .option1:
            
            var index = 0
            while true {
                
                var item1: NFTItem.Property?
                var item2: NFTItem.Property?

                if index < properties.count {
                    
                    item1 = properties[index]
                    index += 1
                }
                
                if index < properties.count {
                    
                    item2 = properties[index]
                    index += 1
                }
                
                guard let item1 = item1 else { break }

                rows.append(
                    makePropertiesRow(
                        with: item1,
                        and: item2
                    )
                )
                rows.append(.vSpace(height: Global.padding))
            }
            
        case .option2:
                        
            properties.forEach {
                
                let containerView = UIView()
                containerView.backgroundColor = .clear
                let item = makePropertyContent(with: $0, layout: .option2)
                containerView.addSubview(item)
                item.addConstraints(
                    [
                        .layout(anchor: .topAnchor),
                        .layout(anchor: .bottomAnchor),
                        .layout(
                            anchor: .widthAnchor,
                            constant: .equalTo(constant: propertyItemSize.width)
                        ),
                        .layout(anchor: .centerXAnchor)
                    ]
                )
                
                rows.append(containerView)

                rows.append(.vSpace(height: Global.padding))
            }
        }
        
        return VStackView(rows)
    }
}

private extension NFTDetailViewController {
    
    var propertyItemSize: CGSize {
        
        let width: CGFloat
        if let view = navigationController?.view {
            width = view.frame.size.width
        } else {
            width = 220
        }
        
        return .init(
            width: (width - Global.padding * 9),
            height: 80
        )
    }
    
    func makePropertiesRow(
        with item1: NFTItem.Property,
        and item2: NFTItem.Property?
    ) -> UIView {
        
        var views = [UIView]()
        
        views.append(makePropertyContent(with: item1, layout: .option1))
        if let item2 = item2 {
            views.append(makePropertyContent(with: item2, layout: .option1))
        } else {
            views.append(UIView())
        }
        
        let hStack = HStackView(views, spacing: Global.padding)
        
        let view = UIView()
        view.backgroundColor = .clear
        view.addSubview(hStack)
        hStack.addConstraints(
            [
                .layout(anchor: .centerXAnchor),
                .layout(anchor: .topAnchor),
                .layout(anchor: .bottomAnchor)
            ]
        )
        
        return view
    }
    
    func makePropertyContent(
        with item: NFTItem.Property,
        layout: PropertyLayout
    ) -> UIView {
        
        let view = UIView()
        
        let stackView = makeVerticalStack(with: item)
        view.addSubview(stackView)
        switch layout {
        case .option1:
            stackView.addConstraints(
                [
                    .layout(anchor: .centerXAnchor),
                    .layout(anchor: .centerYAnchor)
                ]
            )
        case .option2:
            stackView.addConstraints(
                [
                    .layout(anchor: .leadingAnchor, constant: .equalTo(constant: Global.padding)),
                    .layout(anchor: .trailingAnchor, constant: .equalTo(constant: Global.padding)),
                    .layout(anchor: .topAnchor, constant: .equalTo(constant: Global.padding)),
                    .layout(anchor: .bottomAnchor, constant: .equalTo(constant: Global.padding))
                ]
            )
        }
        
//        view.addConstraints(
//            [
//                .layout(
//                    anchor: .widthAnchor,
//                    constant: .equalTo(constant: propertyItemSize.width)
//                )
//            ]
//        )

        view.layer.cornerRadius = 16
        view.layer.borderWidth = 1
        view.layer.borderColor = Theme.color.tintLight.cgColor
        view.clipsToBounds = true
        view.backgroundColor = Theme.color.backgroundDark
        return view
    }
    
    func makeVerticalStack(
        with item: NFTItem.Property
    ) -> UIView {
        
        let view = VStackView()
        
        let topLabel = UILabel(with: .smallerLabel)
        topLabel.numberOfLines = 1
        topLabel.text = item.name
        topLabel.textColor = Theme.color.text
        topLabel.textAlignment = .center
        view.addArrangedSubview(topLabel)
        
        view.addArrangedSubview(.vSpace(height: 8))
        
        let middleLabel = UILabel(with: .smallerLabel)
        middleLabel.numberOfLines = 1
        middleLabel.text = item.value
        middleLabel.textColor = Theme.color.green
        middleLabel.textAlignment = .center
        view.addArrangedSubview(middleLabel)

        view.addArrangedSubview(.vSpace(height: 8))
        
        let bottomLabel = UILabel(with: .smallerLabel)
        bottomLabel.numberOfLines = 1
        bottomLabel.text = item.info
        bottomLabel.textColor = Theme.color.text
        bottomLabel.textAlignment = .center
        view.addArrangedSubview(bottomLabel)
                
        return view
    }
}
