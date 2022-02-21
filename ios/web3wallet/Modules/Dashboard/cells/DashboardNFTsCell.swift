// Created by web3d3v on 19/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

class DashboardNFTsCell: CollectionViewCell {
    
    @IBOutlet weak var carousel: iCarousel!
    
    private var viewModel: [DashboardViewModel.NFT] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = Global.cornerRadius * 2
        carousel.dataSource = self
        carousel.type = .coverFlow
    }
}

// MARK: - DashboardViewModel

extension DashboardNFTsCell {

    func update(with viewModel: [DashboardViewModel.NFT]) {
        self.viewModel = viewModel
        carousel.reloadData()
    }
}


// MARK -

extension DashboardNFTsCell: iCarouselDataSource {

    func numberOfItems(in carousel: iCarousel) -> Int {
        viewModel.count
    }

    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        let imageView = view as? UIImageView ?? UIImageView()
        imageView.image = UIImage(named: viewModel[index].imageName ?? "")
        let length = min(carousel.bounds.width, carousel.bounds.height) * 0.9
        imageView.bounds.size = CGSize(width: length, height: length)
        imageView.backgroundColor = UIColor.bgGradientTopSecondary
        return imageView
    }
}
