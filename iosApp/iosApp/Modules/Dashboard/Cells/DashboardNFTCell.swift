// Created by web3d3v on 19/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

final class DashboardNFTCell: CollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        layer.cornerRadius = Global.cornerRadius * 2
        clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
    }

    override func prepareForReuse() {
        
        super.prepareForReuse()
        
        layer.transform = CATransform3DIdentity
        layer.removeAllAnimations()
    }
}

extension DashboardNFTCell {

    func update(with viewModel: DashboardViewModel.NFT) {
        
        imageView.load(url: viewModel.image)
    }
}