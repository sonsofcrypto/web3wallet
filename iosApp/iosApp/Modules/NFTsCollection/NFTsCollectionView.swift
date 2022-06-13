// Created by web3d4v on 29/05/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol NFTsCollectionView: AnyObject {

    func update(with viewModel: NFTsCollectionViewModel)
}

final class NFTsCollectionViewController: BaseViewController {

    var presenter: NFTsCollectionPresenter!
    
    private (set) weak var mainScrollView: UIScrollView!
    weak var scrollableContentView: UIView!

    private (set) var viewModel: NFTsCollectionViewModel?
    
    init() { super.init(nibName: nil, bundle: nil) }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        configureUI()

        refresh()
    }
    
    @objc override func dismissAction() {
        
        presenter.handle(.dismiss)
    }
}

extension NFTsCollectionViewController: NFTsCollectionView {
    
    @objc func refresh() {
        
        presenter.present()
    }

    func update(with viewModel: NFTsCollectionViewModel) {

        self.viewModel = viewModel
        
        self.mainScrollView.refreshControl?.endRefreshing()
        
        switch viewModel {
            
        case .loading:
            break
            
        case let .loaded(collection, _):

            title = collection.title
            refreshNFTs()
            
        case .error:
            break
        }
    }
}

private extension NFTsCollectionViewController {
    
    func configureUI() {
        
        title = Localized("nfts")
        
        view = GradientView()
        
        (view as? GradientView)?.colors = [
            Theme.color.background,
            Theme.color.backgroundDark
        ]
        
        let mainScrollView = makeMainScrollView()
        view.addSubview(mainScrollView)
        self.mainScrollView = mainScrollView
        mainScrollView.addConstraints(.toEdges)
        
        addCloseButtonToNavigationBar()
    }
}
