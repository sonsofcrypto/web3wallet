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
        
        let imageView = view as? NFTLoadingView ?? NFTLoadingView()
        imageView.configure(with: item)
        let length = min(
            carousel.bounds.width, carousel.bounds.height
        ) * 0.9
        imageView.bounds.size = CGSize(width: length, height: length)
        
        return imageView
    }
}

extension NFTsDashboardViewController: iCarouselDelegate {
    
    func carousel(_ carousel: iCarousel, didSelectItemAt index: Int) {
        
        guard let item = viewModel?.nfts[index] else { return }
        presenter.handle(.viewNFT(identifier: item.identifier))
    }
}

final class NFTLoadingView: UIView {
    
    private weak var imageView: UIImageView!
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with item: NFTsDashboardViewModel.NFT) {
        
        imageView.load(url: item.image)
    }
}

private extension NFTLoadingView {
    
    func commonInit() {
        
        backgroundColor = UIColor.bgGradientTopSecondary
        
        let imageView = UIImageView()
        addSubview(imageView)
        self.imageView = imageView
        imageView.addConstraints(.toEdges)
    }
}
