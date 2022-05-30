// Created by web3d4v on 27/05/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

extension NFTDetailViewController {
    
    func refreshNFT(with item: NFTItem, and collection: NFTCollection) {
        
        scrollableContentView.clearSubviews()
        
        let content = makeNFTContent(with: item, and: collection)
        scrollableContentView.addSubview(content)
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

private extension NFTDetailViewController {
    
    func makeNFTContent(
        with item: NFTItem,
        and collection: NFTCollection
    ) -> UIView {
        
        let vStackView = VStackView()
        
        let nftImageView = makeNFTImage(with: item)
        vStackView.addArrangedSubview(nftImageView)
        
        vStackView.addArrangedSubview(.vSpace(height: Global.padding))
        
//        let priceView = makeEthPrice(with: item)
//        vStackView.addArrangedSubview(priceView)
        
        let descriptionView = makeDescription(with: collection)
        vStackView.addArrangedSubview(.vSpace(height: Global.padding))
        vStackView.addArrangedSubview(descriptionView)

        if let propertiesView = makeProperties(with: item) {
            vStackView.addArrangedSubview(.vSpace(height: Global.padding * 2))
            vStackView.addArrangedSubview(propertiesView)
        }

        vStackView.addArrangedSubview(.vSpace(height: Global.padding * 2))

        return vStackView
    }
}
