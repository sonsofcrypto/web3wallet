// Created by web3d4v on 24/05/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol NFTsDashboardView: AnyObject {

    func update(with viewModel: NFTsDashboardViewModel)
    func popToRootAndRefresh()
}

final class NFTsDashboardViewController: BaseViewController {

    var presenter: NFTsDashboardPresenter!
    
    private (set) weak var mainScrollView: ScrollView?
    weak var loadingView: UIActivityIndicatorView?
    weak var noContentView: UIView?
    weak var carousel: iCarousel?
    weak var collectionsView: UIView?

    private (set) var viewModel: NFTsDashboardViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        presenter.present(isPullDownToRefreh: false)
    }
    
    deinit {
        presenter.releaseResources()
    }
}

extension NFTsDashboardViewController: NFTsDashboardView {

    func update(with viewModel: NFTsDashboardViewModel) {
        
        switch viewModel {
        case .loading:
            
            guard self.viewModel?.nfts.isEmpty ?? true else { return }
            showLoading()
        case .error:
            // TODO: Improve and show error
            showNoNFTs()
        case .loaded:
            mainScrollView?.refreshControl?.endRefreshing()
            self.viewModel = viewModel
            if viewModel.nfts.isEmpty {
                showNoNFTs()
            } else {
                showNFTs()
            }
        }
    }
    
    func popToRootAndRefresh() {
        
        navigationController?.popToRootViewController(animated: false)
        presenter.present(isPullDownToRefreh: true)
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
    
    @objc func pullDownToRefresh() {
        
        presenter.present(isPullDownToRefreh: true)
    }
}

private extension NFTsDashboardViewController {
    
    func showLoading() {
        
        loadingView?.isHidden = false
        loadingView?.startAnimating()
        noContentView?.isHidden = true
        mainScrollView?.isHidden = true
    }

    func hideLoading() {
        
        loadingView?.isHidden = true
        loadingView?.stopAnimating()
    }

    func showNoNFTs() {
        
        hideLoading()
        noContentView?.isHidden = false
        mainScrollView?.isHidden = true
    }

    func showNFTs() {
        
        hideLoading()
        noContentView?.isHidden = true
        mainScrollView?.isHidden = false
        refreshNFTs()
        refreshNFTsCollections()
    }

    func configureUI() {
        
        title = Localized("nfts")
        
        let gradient = GradientView()
        view.addSubview(gradient)
        gradient.addConstraints(.toEdges)
        
        let loadingView = UIActivityIndicatorView(style: .large)
        loadingView.color = Theme.colour.activityIndicator
        view.addSubview(loadingView)
        self.loadingView = loadingView
        loadingView.addConstraints(
            [
                .layout(
                    anchor: .topAnchor,
                    constant: .equalTo(constant: Theme.constant.padding * 2)
                ),
                .layout(
                    anchor: .centerXAnchor
                )
            ]
        )

        let noContentView = makeNoContentView()
        view.addSubview(noContentView)
        self.noContentView = noContentView
        noContentView.addConstraints(
            [
                .layout(
                    anchor: .topAnchor,
                    constant: .equalTo(constant: Theme.constant.padding)
                ),
                .layout(
                    anchor: .leadingAnchor,
                    constant: .equalTo(constant: Theme.constant.padding)
                ),
                .layout(
                    anchor: .trailingAnchor,
                    constant: .equalTo(constant: Theme.constant.padding)
                )
            ]
        )
        
        let mainScrollView = makeMainScrollView()
        view.addSubview(mainScrollView)
        self.mainScrollView = mainScrollView
        mainScrollView.addConstraints(.toEdges)
        
        mainScrollView.overScrollView.image = "overscroll_ape".assetImage
        mainScrollView.overScrollView.layer.transform = CATransform3DMakeTranslation(0, -20, 0)
    }
}
