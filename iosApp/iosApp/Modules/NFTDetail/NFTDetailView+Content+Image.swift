// Created by web3d4v on 29/05/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

extension NFTDetailViewController {
    
    func makeNFTImage(with item: NFTItem) -> UIView {
                
        var views = [UIView]()
        
        views.append(.vSpace(height: Global.padding))
        
        let headerImage = makeEthPrice(with: item)
        views.append(headerImage)
        
        views.append(.vSpace(height: Global.padding))
        
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.load(url: item.image)
        views.append(imageView)
        imageView.addConstraints(
            [
                .layout(
                    anchor: .heightAnchor,
                    constant: .equalTo(constant: nftImageSize.height)
                ),
                .layout(
                    anchor: .widthAnchor,
                    constant: .equalTo(constant: nftImageSize.width)
                )
            ]
        )
        
        let containerView = UIView()
        let vStackView = VStackView(views)
        vStackView.clipsToBounds = true
        containerView.addSubview(vStackView)
        vStackView.addConstraints(
            [
                .layout(anchor: .topAnchor),
                .layout(anchor: .bottomAnchor),
                .layout(anchor: .centerXAnchor)
            ]
        )
        
        vStackView.backgroundColor = Theme.color.backgroundDark
        vStackView.layer.cornerRadius = Global.cornerRadius
        vStackView.layer.cornerRadius = Global.cornerRadius
        vStackView.layer.borderWidth = 1
        vStackView.layer.borderColor = Theme.color.tintLight.cgColor

        return containerView
    }
}

private extension NFTDetailViewController {
    
    func makeHeaderImage(with item: NFTItem) -> UIView {
        
        let label = UILabel(with: .headlineGlow)
        label.text = item.name
        label.textAlignment = .center
        return label
    }
    
    var nftImageSize: CGSize {
        
        let width: CGFloat
        if let view = navigationController?.view {
            width = view.frame.size.width - Global.padding * 3
        } else {
            width = 220
        }
        
        return .init(
            width: width * 0.9,
            height: width * 0.9
        )
    }
}
