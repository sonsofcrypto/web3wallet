// Created by web3d4v on 24/05/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

extension NFTsDashboardViewController {
    
    func makeNFTCollectionsContent() -> UIStackView {
        
        let collections = viewModel?.collections ?? []
        
        guard !collections.isEmpty else {

            // NOTE: No content will be handled in the future, for now the data is mocked
            // and will always return a few collections
            return HStackView([])
        }

        var rows: [UIView] = []
        
        let titleLabel = UILabel(with: .bodyGlow)
        titleLabel.numberOfLines = 1
        titleLabel.text = Localized("nfts.dashboard.collection.title")
        //titleLabel.textColor = Theme.current.color.red
        titleLabel.textAlignment = .center
        rows.append(titleLabel)
        
        var index = 0
        while true {
            
            var item1: NFTsDashboardViewModel.Collection?
            var item2: NFTsDashboardViewModel.Collection?

            if index < collections.count {
                
                item1 = collections[index]
                index += 1
            }
            
            if index < collections.count {
                
                item2 = collections[index]
                index += 1
            }
            
            guard let item1 = item1 else { break }

            rows.append(makeNFTsCollectionRow(with: item1, and: item2))
        }
        
        rows.append(.vSpace(height: Global.padding))
                
        return VStackView(rows, spacing: Global.padding)
    }
    
    func refreshNFTsCollections() {
        
        collectionsView.clearSubviews()
        
        let content = makeNFTCollectionsContent()
        collectionsView.addSubview(content)
        content.addConstraints(
            [
                .layout(anchor: .topAnchor),
                .layout(anchor: .bottomAnchor),
                .layout(anchor: .leadingAnchor, constant: .equalTo(constant: Global.padding)),
                .layout(anchor: .trailingAnchor, constant: .equalTo(constant: Global.padding))
            ]
        )
    }
}

private extension NFTsDashboardViewController {
    
    func makeNFTsCollectionRow(
        with item1: NFTsDashboardViewModel.Collection,
        and item2: NFTsDashboardViewModel.Collection?
    ) -> UIView {
        
        var views = [UIView]()
        
        views.append(makePopularNFTCollectionContent(with: item1))
        if let item2 = item2 {
            views.append(makePopularNFTCollectionContent(with: item2))
        } else {
            views.append(UIView())
        }
        return HStackView(views, spacing: Global.padding)
    }
    
    func makePopularNFTCollectionContent(
        with collection: NFTsDashboardViewModel.Collection
    ) -> UIView {
        
        let view = UIView()
        
        let stackView = makeVerticalStack(with: collection)
        view.addSubview(stackView)
        stackView.addConstraints(
            [
                .layout(anchor: .topAnchor),
                .layout(anchor: .leadingAnchor),
                .layout(anchor: .trailingAnchor)
            ]
        )
        
        view.addConstraints(
            [
                .layout(
                    anchor: .widthAnchor,
                    constant: .equalTo(constant: collectionItemSize.width)
                ),
                .layout(
                    anchor: .heightAnchor,
                    constant: .equalTo(constant: collectionItemSize.height)
                )
            ]
        )

        view.layer.cornerRadius = 16
        view.layer.borderWidth = 1
        view.layer.borderColor = Theme.color.tintLight.cgColor
        view.clipsToBounds = true
        
//        let imageDiameter: CGFloat = 80
//        let imageView = UIImageView()
//        imageView.clipsToBounds = true
//        imageView.contentMode = .scaleAspectFill
//        imageView.layer.cornerRadius = imageDiameter * 0.5
//        imageView.layer.borderWidth = 3
//        imageView.layer.borderColor = Theme.color.tint.cgColor
//        imageView.load(url: collection.authorImage)
//        view.addSubview(imageView)
//        imageView.addConstraints(
//            [
//                .layout(
//                    anchor: .topAnchor,
//                    constant: .equalTo(
//                        constant: (collectionItemSize.width * 0.6) - (imageDiameter * 0.5)
//                    )
//                ),
//                .layout(anchor: .centerXAnchor),
//                .layout(
//                    anchor: .widthAnchor,
//                    constant: .equalTo(constant: imageDiameter)
//                ),
//                .layout(
//                    anchor: .heightAnchor,
//                    constant: .equalTo(constant: imageDiameter)
//                )
//            ]
//        )
        
        return view
    }
    
    func makeVerticalStack(
        with collection: NFTsDashboardViewModel.Collection
    ) -> UIView {
        
        let view = VStackView()
        
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.load(url: collection.coverImage)
        view.addArrangedSubview(imageView)
        imageView.addConstraints(
            [
                .layout(
                    anchor: .heightAnchor,
                    constant: .equalTo(constant: collectionItemSize.width * 0.6)
                )
            ]
        )
        
        view.addArrangedSubview(.vSpace(height: 8))
        
        let font = UIFont.font(.gothicA1, style: .medium, size: .caption2)
        
        let titleLabel = UILabel(with: .smallerLabel)
        titleLabel.numberOfLines = 1
        titleLabel.text = collection.title
        titleLabel.textColor = Theme.current.color.text
        titleLabel.textAlignment = .center
        view.addArrangedSubview(titleLabel)

        let authorLabel = UILabel()
        authorLabel.numberOfLines = 1
        authorLabel.attributedText = Localized(
            "nfts.dashboard.collection.popular.author",
            arg: collection.author
        ).attributtedString(
            with: font,
            and: Theme.current.color.text,
            updating: [collection.author],
            withColour: Theme.current.color.red,
            andFont: font
        )
        authorLabel.layer.applyShadow(Theme.color.tintSecondary)
        authorLabel.textAlignment = .center
        view.addArrangedSubview(authorLabel)
        view.spacing = Global.padding * 0.5
                
        return view
    }
}
