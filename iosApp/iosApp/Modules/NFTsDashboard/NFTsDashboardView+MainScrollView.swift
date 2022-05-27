// Created by web3d4v on 24/05/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

extension NFTsDashboardViewController {
    
    func makeMainScrollView() -> UIScrollView {
        
        let mainScrollView = UIScrollView()
        mainScrollView.showsHorizontalScrollIndicator = false
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = Theme.color.tintLight
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        mainScrollView.refreshControl = refreshControl
        
        let carousel = iCarousel(frame: .zero)
        carousel.type = .coverFlow
        carousel.dataSource = self
        carousel.delegate = self
        carousel.layer.cornerRadius = Global.cornerRadius
        carousel.layer.borderWidth = 1
        carousel.layer.borderColor = Theme.color.tintLight.cgColor
        mainScrollView.addSubview(carousel)
        carousel.clipsToBounds = true
        self.carousel = carousel
        carousel.addConstraints(
            [
                .layout(anchor: .topAnchor, constant: .equalTo(constant: Global.padding)),
                .layout(anchor: .heightAnchor, constant: .equalTo(constant: 162)),
                .layout(anchor: .widthAnchor, constant: .equalTo(constant: carouselWidth)),
                .layout(anchor: .centerXAnchor)
            ]
        )
        
        let collectionsView = UIView()
        mainScrollView.addSubview(collectionsView)
        self.collectionsView = collectionsView
        collectionsView.addConstraints(
            [
                .layout(anchor: .topAnchor, constant: .equalTo(constant: 200)),
                .layout(anchor: .bottomAnchor),
                .layout(anchor: .centerXAnchor),
                .layout(anchor: .widthAnchor)
            ]
        )
        
        return mainScrollView
    }
}

private extension NFTsDashboardViewController {
    
    var carouselWidth: CGFloat {
     
        let width = navigationController?.view.frame.width ?? 0
        
        return width - Global.padding * 2
    }
}
