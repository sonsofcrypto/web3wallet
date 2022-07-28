// Created by web3d4v on 27/05/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol NFTDetailView: AnyObject {

    func update(with viewModel: NFTDetailViewModel)
}

final class NFTDetailViewController: BaseViewController {

    var presenter: NFTDetailPresenter!
    
    private (set) weak var mainScrollView: UIScrollView!
    weak var scrollableContentView: UIView!

    private (set) var viewModel: NFTDetailViewModel?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        configureUI()

        refresh()
    }
}

extension NFTDetailViewController: NFTDetailView {
    
    @objc func refresh() {
        
        presenter.present()
    }

    func update(with viewModel: NFTDetailViewModel) {

        self.viewModel = viewModel
        
        self.mainScrollView.refreshControl?.endRefreshing()
        
        switch viewModel {
            
        case .loading:
            break
            
        case let .loaded(nftItem, nftCollection):

            title = nftItem.name
            refreshNFT(with: nftItem, and: nftCollection)
            
        case .error:
            break
        }
    }
}

private extension NFTDetailViewController {
    
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
    }
    
    @objc func dismissTapped() {
        
        presenter.handle(.dismiss)
    }

}
