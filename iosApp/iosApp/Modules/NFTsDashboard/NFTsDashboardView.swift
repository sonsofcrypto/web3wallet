// Created by web3d4v on 24/05/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

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
        presenter.present(isPullDownToRefresh: false)
    }
    
    deinit {
        presenter.releaseResources()
    }
}

extension NFTsDashboardViewController {

    func update(with viewModel: NFTsDashboardViewModel) {
        if viewModel is NFTsDashboardViewModel.Loading {
            guard self.viewModel?.nftItems.isEmpty ?? true else { return }
            showLoading()
        }
        if let input = viewModel as? NFTsDashboardViewModel.Error {
            presentError(with: input.error)
        }
        if viewModel is NFTsDashboardViewModel.Loaded {
            noContentView?.refreshControl?.endRefreshing()
            mainScrollView?.refreshControl?.endRefreshing()
            self.viewModel = viewModel
            if viewModel.nftItems.isEmpty { showNoNFTs() }
            else { showNFTs() }
        }
    }
    
    func popToRootAndRefresh() {
        navigationController?.popToRootViewController(animated: false)
        presenter.present(isPullDownToRefresh: true)
    }
}

extension NFTsDashboardViewController {
    
    var collectionItemSize: CGSize {
        let width: CGFloat
        if let view = navigationController?.view {
            width = view.frame.size.width - Theme.padding * 3
        } else {
            width = 220
        }
        return .init(
            width: width * 0.5,
            height: width * 0.5
        )
    }
    
    @objc func pullDownToRefresh() {
        presenter.present(isPullDownToRefresh: true)
    }
    
    @objc func refreshNoContent() {
        showLoading()
        presenter.present(isPullDownToRefresh: true)
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
        edgesForExtendedLayout = []
        title = Localized("nfts")
        let gradient = ThemeGradientView()
        view.addSubview(gradient)
        gradient.addConstraints(.toEdges)
        let loadingView = UIActivityIndicatorView(style: .large)
        loadingView.color = Theme.color.activityIndicator
        view.addSubview(loadingView)
        self.loadingView = loadingView
        loadingView.addConstraints(
            [
                .layout(
                    anchor: .topAnchor,
                    constant: .equalTo(constant: Theme.padding * 2)
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
    
    func presentError(with viewModel: ErrorViewModel) {
        guard viewModel.actions.count == 2 else { return }
        let alert = UIAlertController(
            title: viewModel.title,
            message: viewModel.body,
            preferredStyle: .alert)
        alert.addAction(
            .init(
                title: viewModel.actions[0],
                style: .cancel,
                handler: { [weak self] _ in self?.presenter.handle(
                    event: NFTsDashboardPresenterEvent.CancelError())
                }
            )
        )
        alert.addAction(
            .init(
                title: viewModel.actions[1],
                style: .default,
                handler: { [weak self] _ in self?.presenter.handle(
                    event: NFTsDashboardPresenterEvent.SendError())
                }
            )
        )
        present(alert, animated: true)
    }
}

extension NFTsDashboardViewModel {
    var nftItems: [NFTsDashboardViewModel.NFT] {
        guard let input = self as? NFTsDashboardViewModel.Loaded else { return [] }
        return input.nfts
    }
}
