// Created by web3d4v on 29/05/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import web3walletcore

extension NFTDetailViewController {
    
    func makeEthPrice(with item: NFTItem) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        let content = makeEthPriceContent(with: item)
        view.addSubview(content)
        content.addConstraints(.toEdges)
        return view
    }
        
    func makeEthPriceContent(with item: NFTItem) -> UIView {
        let hStackView = HStackView()
        hStackView.spacing = Theme.padding * 0.5
        let iconImage = UIImageView(image: "ethereum-icon".assetImage)
        iconImage.tintColor = Theme.color.textPrimary
        iconImage.addConstraints(
            [
                .layout(anchor: .widthAnchor, constant: .equalTo(constant: 14)),
                .layout(anchor: .heightAnchor, constant: .equalTo(constant: 20))
            ]
        )
        hStackView.addArrangedSubview(iconImage)
//        let ethPrice = UILabel(with: .headline)
//        ethPrice.textAlignment = .center
//        ethPrice.text = "\(item.ethPrice)"
//        
//        hStackView.addArrangedSubview(ethPrice)
        let groupView = UIView()
        groupView.addSubview(hStackView)
        hStackView.addConstraints(
            [
                .layout(anchor: .centerXAnchor),
                .layout(anchor: .centerYAnchor)
            ]
        )
        groupView.addConstraints(
            [
                .layout(
                    anchor: .heightAnchor,
                    constant: .equalTo(
                        constant: 20
                    )
                )
            ]
        )
        return groupView
    }
}
