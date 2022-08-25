// Created by web3d4v on 24/05/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

extension NFTsDashboardViewController {
    
    typealias NFTCollectionItem = (
        index: Int,
        collection: NFTsDashboardViewModel.Collection
    )
    
    func makeNFTCollectionsContent() -> UIStackView {
        
        let collections = viewModel?.collections ?? []
        
        guard !collections.isEmpty else {

            // NOTE: No content will be handled in the future, for now the data is mocked
            // and will always return a few collections
            return HStackView([])
        }

        var rows: [UIView] = []
        
        let titleLabel = UILabel(with: .title3)
        titleLabel.numberOfLines = 1
        titleLabel.text = Localized("nfts.dashboard.collection.title")
        //titleLabel.textColor = Theme.colour.systemRed
        titleLabel.textAlignment = .center
        rows.append(titleLabel)
        
        var index = 0
        while true {
            
            var item1: NFTCollectionItem?
            var item2: NFTCollectionItem?

            if index < collections.count {
                
                item1 = (index: index, collection: collections[index])
                index += 1
            }
            
            if index < collections.count {
                
                item2 = (index: index, collection: collections[index])
                index += 1
            }
            
            guard let item1 = item1 else { break }

            rows.append(
                makeNFTsCollectionRow(
                    with: item1,
                    and: item2
                )
            )
        }
        
        return VStackView(rows, spacing: Theme.constant.padding)
    }
    
    func refreshNFTsCollections() {
        
        collectionsView?.removeAllSubview()
        
        let content = makeNFTCollectionsContent()
        collectionsView?.addSubview(content)
        content.addConstraints(
            [
                .layout(anchor: .topAnchor),
                .layout(anchor: .bottomAnchor, constant: .equalTo(constant: Theme.constant.padding)),
                .layout(anchor: .leadingAnchor, constant: .equalTo(constant: Theme.constant.padding)),
                .layout(anchor: .trailingAnchor, constant: .equalTo(constant: Theme.constant.padding))
            ]
        )
    }
}

private extension NFTsDashboardViewController {
    
    func makeNFTsCollectionRow(
        with item1: NFTCollectionItem,
        and item2: NFTCollectionItem?
    ) -> UIView {
        
        var views = [UIView]()
        
        views.append(makePopularNFTCollectionContent(with: item1))
        if let item2 = item2 {
            views.append(makePopularNFTCollectionContent(with: item2))
        } else {
            views.append(UIView())
        }
        return HStackView(views, spacing: Theme.constant.padding)
    }
    
    func makePopularNFTCollectionContent(
        with item: NFTCollectionItem
    ) -> UIView {
        
        let view = UIView()
        
        let stackView = makeVerticalStack(with: item.collection)
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

        view.layer.cornerRadius = Theme.constant.cornerRadius
        view.layer.borderWidth = 1
        view.layer.borderColor = Theme.colour.fillTertiary.cgColor
        view.backgroundColor = Theme.colour.backgroundBasePrimary
        view.clipsToBounds = true
        
        view.tag = item.index
        view.add(
            .targetAction(
                .init(target: self, selector: #selector(collectionItemSelected(_:)))
            )
        )
        return view
    }
    
    @objc func collectionItemSelected(_ tapGesture: UITapGestureRecognizer) {
        
        guard let tag = tapGesture.view?.tag else { return }
        guard let viewModel = viewModel else { return }
        guard viewModel.collections.count > tag else { return }
        let collection = viewModel.collections[tag]
        presenter.handle(.viewCollectionNFTs(collectionId: collection.identifier))
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
                    constant: .equalTo(constant: collectionItemSize.width * 0.7)
                )
            ]
        )
        
        let font = UIFont.font(.gothicA1, style: .medium, size: .caption2)
        
        let titleLabel = UILabel(with: .caption1)
        titleLabel.numberOfLines = 1
        titleLabel.text = collection.title
        titleLabel.textColor = Theme.colour.labelPrimary
        titleLabel.textAlignment = .center
        view.addArrangedSubview(titleLabel)

        let authorLabel = UILabel()
        authorLabel.numberOfLines = 1
        authorLabel.attributedText = Localized(
            "nfts.dashboard.collection.popular.author",
            arg: collection.author
        ).attributtedString(
            with: font,
            and: Theme.colour.labelPrimary,
            updating: [collection.author],
            withColour: Theme.colour.labelPrimary,
            andFont: font
        )
        authorLabel.layer.applyShadow(Theme.colour.fillSecondary)
        authorLabel.textAlignment = .center
        view.addArrangedSubview(authorLabel)
        view.spacing = Theme.constant.padding * 0.5
                
        return view
    }
}
