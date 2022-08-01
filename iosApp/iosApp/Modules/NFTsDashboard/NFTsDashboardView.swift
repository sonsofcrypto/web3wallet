// Created by web3d4v on 24/05/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol NFTsDashboardView: AnyObject {

    func update(with viewModel: NFTsDashboardViewModel)
}

final class NFTsDashboardViewController: BaseViewController {

    var presenter: NFTsDashboardPresenter!
    
    private (set) weak var mainScrollView: ScrollView!
    weak var carousel: iCarousel!
    weak var collectionsView: UIView!

    private (set) var viewModel: NFTsDashboardViewModel?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        configureUI()
        
        refresh()
    }
}

extension NFTsDashboardViewController: NFTsDashboardView {

    func update(with viewModel: NFTsDashboardViewModel) {

        self.viewModel = viewModel
        
        mainScrollView.refreshControl?.endRefreshing()
        
        refreshNFTs()
        refreshNFTsCollections()
    }
}

extension NFTsDashboardViewController {
    
    var collectionItemSize: CGSize {
        
        let width: CGFloat
        if let view = navigationController?.view {
            width = view.frame.size.width - Theme.constant.padding * 3
        } else {
            width = 220
        }
        
        return .init(
            width: width * 0.5,
            height: width * 0.5
        )
    }
    
    @objc func refresh() {
        
        presenter.present()
    }
}

private extension NFTsDashboardViewController {
    
    func configureUI() {
        
        title = Localized("nfts")
        
        let gradient = GradientView()
        view.addSubview(gradient)
        gradient.addConstraints(.toEdges)
        
        let mainScrollView = makeMainScrollView()
        view.addSubview(mainScrollView)
        self.mainScrollView = mainScrollView
        mainScrollView.addConstraints(.toEdges)
        
        mainScrollView.overScrollView.image = "overscroll_ape".assetImage
        mainScrollView.overScrollView.layer.transform = CATransform3DMakeTranslation(0, -20, 0)
    }
}
