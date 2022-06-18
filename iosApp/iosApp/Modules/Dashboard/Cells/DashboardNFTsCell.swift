// Created by web3d3v on 19/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

final class DashboardNFTsCell: CollectionViewCell {
    
    @IBOutlet weak var carousel: iCarousel!
    
    private var viewModel: [DashboardViewModel.NFT] = []
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        layer.cornerRadius = Global.cornerRadius * 2
        
        carousel.dataSource = self
        carousel.delegate = self
        carousel.type = .coverFlow
    }

    override func prepareForReuse() {
        
        super.prepareForReuse()
        
        layer.transform = CATransform3DIdentity
        layer.removeAllAnimations()
    }
}

extension DashboardNFTsCell {

    func update(with viewModel: [DashboardViewModel.NFT]) {
        
        self.viewModel = viewModel
        
        carousel.reloadData()
    }
}

extension DashboardNFTsCell: iCarouselDataSource {

    func numberOfItems(in carousel: iCarousel) -> Int {
        viewModel.count
    }

    func carousel(
        _ carousel: iCarousel,
        viewForItemAt index: Int,
        reusing view: UIView?
    ) -> UIView {
        
        let imageView = view as? UIImageView ?? UIImageView()
        imageView.load(url: viewModel[index].image)
        let length = min(
            carousel.bounds.width,
            carousel.bounds.height
        )
        imageView.bounds.size = .init(width: length, height: length)
        imageView.backgroundColor = UIColor.bgGradientTopSecondary
        return imageView
    }
}

extension DashboardNFTsCell: iCarouselDelegate {
    
    func carousel(_ carousel: iCarousel, didSelectItemAt index: Int) {
        
        viewModel[index].onSelected()
    }
}
