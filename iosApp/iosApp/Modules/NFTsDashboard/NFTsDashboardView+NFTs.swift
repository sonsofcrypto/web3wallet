// Created by web3d4v on 27/05/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

extension NFTsDashboardViewController {
    
    func refreshNFTs() {
        
        carousel.reloadData()
    }
}

extension NFTsDashboardViewController: iCarouselDataSource {
    
    func numberOfItems(in carousel: iCarousel) -> Int {
        viewModel?.nfts.count ?? 0
    }

    func carousel(
        _ carousel: iCarousel,
        viewForItemAt index: Int,
        reusing view: UIView?
    ) -> UIView {
        
        guard let item = viewModel?.nfts[index] else {
            fatalError()
        }
        let imageView = view as? UIImageView ?? UIImageView()
        imageView.load(url: item.image)
        let length = min(carousel.bounds.width, carousel.bounds.height) * 0.9
        imageView.bounds.size = CGSize(width: length, height: length)
        imageView.backgroundColor = UIColor.bgGradientTopSecondary
        return imageView
    }
}

extension NFTsDashboardViewController: iCarouselDelegate {
    
    func carousel(_ carousel: iCarousel, didSelectItemAt index: Int) {
        
        guard let item = viewModel?.nfts[index] else { return }
        print("selected: \(item.identifier)")
    }
}
