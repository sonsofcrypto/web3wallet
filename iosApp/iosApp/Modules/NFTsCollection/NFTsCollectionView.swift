// Created by web3d4v on 29/05/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

final class NFTsCollectionViewController: UICollectionViewController,
    UICollectionViewDelegateFlowLayout {
    
    var presenter: NFTsCollectionPresenter!
    
    private var prevSize: CGSize = .zero
    private var cellSize: CGSize = .zero
    private var cv: CollectionView? { collectionView as? CollectionView }
    private (set) var viewModel: NFTsCollectionViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        presenter.present()
    }
    
    override func traitCollectionDidChange(
        _ previousTraitCollection: UITraitCollection?
    ) {
        super.traitCollectionDidChange(previousTraitCollection)
        applyTheme(Theme)
        recomputeSizeIfNeeded(true)
        cv?.collectionViewLayout.invalidateLayout()
    }
    
    // MARK: - NFTsCollectionView
    
    func update(with viewModel: NFTsCollectionViewModel) {
        if viewModel is NFTsCollectionViewModel.Loading {
            collectionView.refreshControl?.beginRefreshing()
        } else {
            collectionView.refreshControl?.endRefreshing()
        }
        if viewModel is NFTsCollectionViewModel.Loaded {
            self.viewModel = viewModel
            title = viewModel.collection()?.title ?? title
            collectionView.reloadData()
        }
    }
    
    // MARK: - UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }

    override func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        viewModel?.nfts_().count ?? 0
    }

    override func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        return collectionView.dequeue(ImageViewCell.self, for: indexPath)
            .update(with: viewModel?.nfts_()[indexPath.item])
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        recomputeSizeIfNeeded()
        return cellSize
    }
    
    // MARK: - UICollectionViewDelegate

    override func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        presenter.handleEvent(.Select(idx: indexPath.item.int32))
    }
    
    // MARK: - Actions
    
    @objc func refreshAction(_ sender: Any?) {
        presenter.present()
    }
}

private extension NFTsCollectionViewController {
    
    func configureUI() {
        title = Localized("nfts")
        cv?.overscrollView = UIImageView(imgName: "overscroll_ape")
        cv?.refreshControl = UIRefreshControl()
        cv?.refreshControl?.addTarget(
            self,
            action: #selector(refreshAction(_:)),
            for: .valueChanged
        )
        applyTheme(Theme)
        
    }
    
    func recomputeSizeIfNeeded(_ force: Bool = false) {
        guard prevSize.width != view.bounds.size.width || force else { return }
        prevSize = view.bounds.size
        let length = floor((view.bounds.width - Theme.padding * 3) / 2)
        cellSize = .init(width: length, height: length)
    }
    
    func applyTheme(_ theme: ThemeProtocol) {
        cv?.contentInset.bottom = Theme.padding.twice
        cv?.contentInset.top = Theme.padding
        cv?.refreshControl?.tintColor = Theme.color.textPrimary
    }
}
