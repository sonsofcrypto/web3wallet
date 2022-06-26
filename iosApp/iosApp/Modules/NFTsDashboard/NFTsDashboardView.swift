// Created by web3d4v on 24/05/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol NFTsDashboardView: AnyObject {

    func update(with viewModel: NFTsDashboardViewModel)
}

final class NFTsDashboardViewController: BaseViewController {

    var presenter: NFTsDashboardPresenter!
    
    private (set) weak var mainScrollView: UIScrollView!
    weak var carousel: iCarousel!
    weak var collectionsView: UIView!

    private (set) var viewModel: NFTsDashboardViewModel?
    
    init() { super.init(nibName: nil, bundle: nil) }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        configureUI()
        
        refresh()
    }
}

extension NFTsDashboardViewController: NFTsDashboardView {

    func update(with viewModel: NFTsDashboardViewModel) {

        self.viewModel = viewModel
        
        self.mainScrollView.refreshControl?.endRefreshing()
        
        refreshNFTs()
        refreshNFTsCollections()
    }
}

extension NFTsDashboardViewController {
    
    var collectionItemSize: CGSize {
        
        let width: CGFloat
        if let view = navigationController?.view {
            width = view.frame.size.width - Global.padding * 3
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
        
        view = GradientView()
        //view.addConstraints(.toEdges)
        
        let mainScrollView = makeMainScrollView()
        view.addSubview(mainScrollView)
        self.mainScrollView = mainScrollView
        mainScrollView.addConstraints(.toEdges)
    }
}
