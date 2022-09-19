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
    weak var noContentView: ScrollView?
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
        case let .error(viewModel):
            let alert = UIAlertController(
                title: viewModel.title,
                message: viewModel.message,
                preferredStyle: .alert)
            alert.addAction(
                .init(
                    title: "Cancel",
                    style: .cancel,
                    handler: { [weak self] _ in self?.presenter.handle(.cancelError) }
                )
            )
            alert.addAction(
                .init(
                    title: "Send error logs",
                    style: .default,
                    handler: { [weak self] _ in self?.presenter.handle(.sendError) }
                )
            )
            present(alert, animated: true)
        case .loaded:
            noContentView?.refreshControl?.endRefreshing()
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
    
    @objc func refreshNoContent() {
        showLoading()
        presenter.present(isPullDownToRefreh: false)
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
        
        let gradient = ThemeGradientView()
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
        noContentView.addConstraints(.toEdges)
        noContentView.overScrollView.image = "overscroll_ape".assetImage

        let mainScrollView = makeMainScrollView()
        view.addSubview(mainScrollView)
        self.mainScrollView = mainScrollView
        mainScrollView.addConstraints(.toEdges)
        mainScrollView.overScrollView.image = "overscroll_ape".assetImage
    }
}
