// Created by web3d4v on 29/05/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

final class NFTsCollectionViewController: BaseViewController {
    private (set) weak var mainScrollView: UIScrollView!
    weak var scrollableContentView: UIView!

    var presenter: NFTsCollectionPresenter!
    
    private (set) var viewModel: NFTsCollectionViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        refresh()
    }
}

extension NFTsCollectionViewController: NFTsCollectionView {
    
    @objc func refresh() { presenter.present() }

    func update(viewModel: NFTsCollectionViewModel) {
        self.viewModel = viewModel
        self.mainScrollView.refreshControl?.endRefreshing()
        title = viewModel.collection.title
        refreshNFTs()
    }
}

private extension NFTsCollectionViewController {
    
    func configureUI() {
        title = Localized("nfts")
        let mainScrollView = makeMainScrollView()
        view.addSubview(mainScrollView)
        self.mainScrollView = mainScrollView
        mainScrollView.addConstraints(.toEdges)
        let showBack = (navigationController?.viewControllers.count ?? 0) > 1
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: showBack ? "chevron.left".assetImage : "xmark".assetImage,
            style: .plain,
            target: self,
            action: #selector(dismissTapped)
        )
        // TODO: Enable once switcher to collection view
        // (mainScrollView as? ScrollView)?.overScrollView.image = "overscroll_ape".assetImage
    }
    
    @objc func dismissTapped() {
        presenter.handle(event____: NFTsCollectionPresenterEvent.Dismiss())
    }
}
