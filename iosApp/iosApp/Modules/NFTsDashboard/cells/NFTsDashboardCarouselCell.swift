// Created by web3d3v on 30/09/2023.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

class NFTsDashboardCarouselCell: ThemeCell, iCarouselDataSource, iCarouselDelegate {
    @IBOutlet weak var carouselView: iCarousel!

    private var viewModel: [NFTsDashboardViewModel.Loaded.NFT]?
    private var prevSize: CGSize = .zero
    private var cellSize: CGSize = .zero

    override func applyTheme(_ theme: ThemeProtocol) {
        super.applyTheme(theme)
        carouselView.visibleItemViews.forEach {
            ($0 as? UIImageView)?.backgroundColor = theme.color.bgPrimary
            ($0 as? UIImageView)?.layer.cornerRadius = Theme.cornerRadius
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if recomputeCellSize() {
            carouselView.reloadData()
        }
    }

    func update(with viewModel: [NFTsDashboardViewModel.Loaded.NFT]?) -> Self {
        self.viewModel = viewModel
        carouselView.reloadData()
        return self
    }
    
    private func recomputeCellSize() -> Bool {
        guard prevSize != bounds.size else { return false }
        let length = min(bounds.width, bounds.height)
        cellSize = .init(width: length, height: length)
        prevSize = bounds.size
        carouselView.type = .coverFlow
        return true
    }

    // MARK: - iCarouselDataSource

    func numberOfItems(in carousel: iCarousel) -> Int {
        viewModel?.count ?? 0
    }

    func carousel(
        _ carousel: iCarousel,
        viewForItemAt index: Int,
        reusing view: UIView?
    ) -> UIView {
        let imageView = view as? UIImageView ?? reusableImageView()
        let nft = viewModel?[index]
        _ = recomputeCellSize()
        imageView.bounds.size = cellSize
        imageView.setImage(
            url: nft?.previewImage ?? nft?.image,
            fallBackUrl: nft?.image,
            fallBackText: nft?.fallbackText
        )
        return imageView
    }

    private func reusableImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.backgroundColor = Theme.color.bgPrimary
        imageView.layer.cornerRadius = Theme.cornerRadius
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }

    // MARK: - iCarouselDataSource
    func carousel(_ carousel: iCarousel, didSelectItemAt index: Int) {
        var superView = self.superview
        while superView != nil {
            if let cv = superView as? UICollectionView {
                let section = cv.indexPath(for: self)?.section ?? 0
                cv.delegate?.collectionView?(
                    cv,
                    didSelectItemAt: .init(item: index, section: section)
                )
                return
            } else {
                superView = superView?.superview
            }
        }
    }
}
