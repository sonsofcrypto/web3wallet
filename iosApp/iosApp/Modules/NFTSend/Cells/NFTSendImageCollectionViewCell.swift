// Created by web3d4v on 04/08/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

final class NFTSendImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        let view = makeNFTImage()
        addSubview(view)
        
        view.addConstraints(
            [
                .layout(anchor: .topAnchor),
                .layout(anchor: .bottomAnchor),
                .layout(anchor: .centerXAnchor)
            ]
        )
    }
}

extension NFTSendImageCollectionViewCell {
    
    func update(
        with nftItem: NFTItem
    ) {
        
        imageView.load(url: nftItem.image)
    }
}

private extension NFTSendImageCollectionViewCell {
    
    func makeNFTImage() -> UIView {
                
        var views = [UIView]()
        
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        self.imageView = imageView
        views.append(imageView)
        imageView.addConstraints(
            [
                .layout(
                    anchor: .heightAnchor,
                    constant: .equalTo(constant: 180)
                ),
                .layout(
                    anchor: .widthAnchor,
                    constant: .equalTo(constant: 180)
                )
            ]
        )
        
        let containerView = UIView()
        let vStackView = VStackView(views)
        vStackView.spacing = Theme.constant.padding.half
        vStackView.clipsToBounds = true
        containerView.addSubview(vStackView)
        vStackView.addConstraints(
            [
                .layout(anchor: .topAnchor),
                .layout(
                    anchor: .bottomAnchor,
                    constant: .equalTo(constant: Theme.constant.padding.half)
                ),
                .layout(anchor: .centerXAnchor)
            ]
        )
        
        vStackView.backgroundColor = Theme.colour.cellBackground
        vStackView.layer.cornerRadius = Theme.constant.cornerRadius
        vStackView.layer.borderWidth = 1
        vStackView.layer.borderColor = Theme.colour.fillTertiary.cgColor

        return containerView
    }
}
