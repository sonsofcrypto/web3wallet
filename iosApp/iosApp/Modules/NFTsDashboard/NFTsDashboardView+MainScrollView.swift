// Created by web3d4v on 24/05/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

extension NFTsDashboardViewController {
    
    func makeMainScrollView() -> ScrollView {
        
        let mainScrollView = ScrollView()
        mainScrollView.showsVerticalScrollIndicator = false
        mainScrollView.showsHorizontalScrollIndicator = false
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = Theme.colour.activityIndicator
        refreshControl.addTarget(self, action: #selector(pullDownToRefresh), for: .valueChanged)
        mainScrollView.refreshControl = refreshControl
        
        let carousel = iCarousel(frame: .zero)
        carousel.type = .coverFlow
        carousel.dataSource = self
        carousel.delegate = self
        carousel.layer.cornerRadius = Theme.constant.cornerRadius
//        carousel.layer.borderWidth = 1
//        carousel.layer.borderColor = Theme.colour.fillTertiary.cgColor
        mainScrollView.addSubview(carousel)
        carousel.clipsToBounds = false
        self.carousel = carousel
        carousel.addConstraints(
            [
                .layout(anchor: .topAnchor, constant: .equalTo(constant: Theme.constant.padding)),
                .layout(anchor: .heightAnchor, constant: .equalTo(constant: nftsCollectionHeight)),
                .layout(anchor: .widthAnchor, constant: .equalTo(constant: carouselWidth)),
                .layout(anchor: .centerXAnchor)
            ]
        )
        
        let collectionsView = UIView()
        mainScrollView.addSubview(collectionsView)
        self.collectionsView = collectionsView
        collectionsView.addConstraints(
            [
                .layout(
                    anchor: .topAnchor,
                    constant: .equalTo(
                        constant: nftsCollectionHeight + Theme.constant.padding * 2
                    )
                ),
                .layout(anchor: .bottomAnchor),
                .layout(anchor: .centerXAnchor),
                .layout(anchor: .widthAnchor)
            ]
        )
        
        return mainScrollView
    }
}

private extension NFTsDashboardViewController {
    
    var nftsCollectionHeight: CGFloat {
        
        guard let viewWidth = navigationController?.view.frame.size.width else {
            
            return 200
        }
        
        return viewWidth * 0.6
    }
    
    var carouselWidth: CGFloat {
     
        let width = navigationController?.view.frame.width ?? 0
        
        return width - Theme.constant.padding * 2
    }
}
