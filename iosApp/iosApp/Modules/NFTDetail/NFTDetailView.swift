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
    
    init() { super.init(nibName: nil, bundle: nil) }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        configureUI()

        refresh()
    }
    
    @objc override func navBarLeftActionTapped() {
        
        presenter.handle(.dismiss)
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
        
        view = GradientView()
        //view.addConstraints(.toEdges)
        
        (view as? GradientView)?.colors = [
            Theme.colour.backgroundBaseSecondary,
            Theme.colour.backgroundBasePrimary
        ]
        
        let mainScrollView = makeMainScrollView()
        view.addSubview(mainScrollView)
        self.mainScrollView = mainScrollView
        mainScrollView.addConstraints(.toEdges)
        
        configureNavBarLeftAction()
    }
}
