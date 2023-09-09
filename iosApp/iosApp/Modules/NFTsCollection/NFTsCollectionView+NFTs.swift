// Created by web3d4v on 29/05/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

extension NFTsCollectionViewController {
    
    typealias NFTCollectionItem = (
        index: Int,
        nft: NFTItem
    )
    
    func makeNFTsContent() -> UIStackView {
        let nfts = viewModel?.nfts ?? []
        guard !nfts.isEmpty else {
        // NOTE: No content will be handled in the future, for now the data is mocked
            // and will always return a few collections
            return HStackView([])
        }
        var rows: [UIView] = []
        var index = 0
        while true {
            var item1: NFTCollectionItem?
            var item2: NFTCollectionItem?
            if index < nfts.count {
                item1 = (index: index, nft: nfts[index])
                index += 1
            }
            if index < nfts.count {
                item2 = (index: index, nft: nfts[index])
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
        return VStackView(rows, spacing: Theme.padding)
    }
    
    func refreshNFTs() {
        scrollableContentView.removeAllSubview()
        let content = makeNFTsContent()
        scrollableContentView.addSubview(content)
        content.addConstraints(
            [
                .layout(anchor: .topAnchor),
                .layout(anchor: .bottomAnchor),
                .layout(anchor: .leadingAnchor, constant: .equalTo(constant: Theme.padding)),
                .layout(anchor: .trailingAnchor, constant: .equalTo(constant: Theme.padding))
            ]
        )
    }
}

private extension NFTsCollectionViewController {
    
    var nftItemSize: CGFloat {
        guard let viewWidth = navigationController?.view.frame.size.width else {
            return 200
        }
        return (viewWidth - Theme.padding * 3) * 0.5
    }
    
    func makeNFTsCollectionRow(
        with item1: NFTCollectionItem,
        and item2: NFTCollectionItem?
    ) -> UIView {
        var views = [UIView]()
        views.append(makeNFTContent(with: item1))
        if let item2 = item2 {
            views.append(makeNFTContent(with: item2))
        } else {
            views.append(UIView())
        }
        return HStackView(views, spacing: Theme.padding)
    }
    
    func makeNFTContent(
        with item: NFTCollectionItem
    ) -> UIView {
        let view = UIView()
        let stackView = makeVerticalStack(with: item.nft)
        view.addSubview(stackView)
        stackView.addConstraints(.toEdges)
        view.addConstraints(
            [
                .layout(
                    anchor: .widthAnchor,
                    constant: .equalTo(constant: nftItemSize)
                ),
                .layout(
                    anchor: .heightAnchor,
                    constant: .equalTo(constant: nftItemSize)
                )
            ]
        )
        view.layer.cornerRadius = Theme.cornerRadius
        view.clipsToBounds = true
        view.tag = item.index
        view.add(
            .targetAction(
                .init(target: self, selector: #selector(nftItemSelected(_:)))
            )
        )
        return view
    }
    
    @objc func nftItemSelected(_ tapGesture: UITapGestureRecognizer) {
        guard let tag = tapGesture.view?.tag else { return }
        guard let viewModel = viewModel else { return }
        guard viewModel.nfts.count > tag else { return }
        presenter.handle(event: NFTsCollectionPresenterEvent.NFTDetail(idx: tag.int32))
    }
    
    func makeVerticalStack(
        with item: NFTItem
    ) -> UIView {
        let view = VStackView()
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.setImage(url: item.gatewayImageUrl)
        view.addArrangedSubview(imageView)
        return view
    }
}
