// Created by web3d4v on 24/05/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

final class NFTsDashboardViewController: UICollectionViewController,
    UICollectionViewDelegateFlowLayout {

    var presenter: NFTsDashboardPresenter!

    private var prevSize: CGSize = .zero
    private var carouselCellSize: CGSize = .zero
    private var emptyCellSize: CGSize = .zero
    private var collectionCellSize: CGSize = .zero
    private var cv: CollectionView? { collectionView as? CollectionView }
    private(set) var viewModel: NFTsDashboardViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        presenter.present()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        recomputeSizeIfNeeded()
    }

    override func traitCollectionDidChange(
        _ previousTraitCollection: UITraitCollection?
    ) {
        super.traitCollectionDidChange(previousTraitCollection)
        applyTheme(Theme)
        recomputeSizeIfNeeded(true)
        cv?.collectionViewLayout.invalidateLayout()
    }

    // MARK: - NFTsDashboardView

    func update(with viewModel: NFTsDashboardViewModel) {
        if viewModel is NFTsDashboardViewModel.Loading {
            collectionView.refreshControl?.beginRefreshing()
        } else {
            collectionView.refreshControl?.endRefreshing()
        }
        if let input = viewModel as? NFTsDashboardViewModel.Error {
            handleError(with: input.error)
        }
        if viewModel is NFTsDashboardViewModel.Loaded {
            self.viewModel = viewModel
            collectionView.reloadData()
        }
    }

    func popToRootAndRefresh() {
        navigationController?.popToRootViewController(animated: true)
        presenter.present()
    }

    // MARK: - UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        guard let viewModel = viewModel else { return 0 }
        // If there are no nfts we still want to show refresh cell
        return viewModel.nfts_().isEmpty ? 1 : 2
    }

    override func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        guard let viewModel = viewModel else { return 0 }
        return section == 0 ? 1 : viewModel.collections_().count
    }

    override func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        if indexPath.section == 0 {
            if viewModel?.nfts_().isEmpty ?? true {
                return collectionView.dequeue(
                    NFTsDashboardRefreshCell.self,
                    for: indexPath
                ).update()
            }
            return collectionView.dequeue(
                NFTsDashboardCarouselCell.self,
                for: indexPath
            ).update(with: viewModel?.nfts_())
        }

        return collectionView.dequeue(
            NFTsDashboardCollectionCell.self,
            for: indexPath
        ).update(with: viewModel?.collections_()[indexPath.item])
    }

    override func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let titleKey = indexPath.section == 1
                ? "nfts.dashboard.section.collections.title"
                : "nfts.dashboard.section.nfts.title"
            return collectionView.dequeue(
                SectionHeaderView.self,
                for: indexPath,
                kind: .header
            ).update(with: Localized(titleKey))
        default:
            fatalError("Failed to handle \(kind) \(indexPath)")
        }
    }

    // MARK: - UICollectionViewDelegateFlowLayout

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        recomputeSizeIfNeeded()
        guard indexPath.section == 0 else { return collectionCellSize }
        return viewModel?.nfts_().count != 0 ? carouselCellSize : emptyCellSize
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        section == 0 && (viewModel?.nfts_().isEmpty ?? true)
            ? .zero
            : String.estimateSize(
                "HEADER",
                font: Theme.font.sectionHeader,
                maxWidth: view.bounds.width,
                extraHeight: Theme.padding.twice
        )
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        section != 0 ?
            UIEdgeInsets.with(left: Theme.padding, right: Theme.padding)
            : .zero
    }


    // MARK: - UICollectionViewDelegate

    override func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        if indexPath.isZero()  && (viewModel?.nfts_().isEmpty ?? true) {
            presenter.handleEvent(.Refresh())
            return
        }
        presenter.handleEvent(
            .Select(section: indexPath.section.int32, idx: indexPath.item.int32)
        )
    }

    @objc func refreshAction(_ sender: Any) {
        presenter.handleEvent(.Refresh())
    }
}

private extension NFTsDashboardViewController {

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
        collectionCellSize = .init(width: length, height: length)
        emptyCellSize = view.frame.inset(by: collectionView.adjustedContentInset).size
        let settings: SettingsService = AppAssembler.resolve()
        let regular = settings.nftCarouselSize == .regular
        carouselCellSize = .init(
            width: view.bounds.width,
            height: length * ( regular ? 1 : 1.25)
        )
    }

    func applyTheme(_ theme: ThemeProtocol) {
        cv?.contentInset.bottom = Theme.padding
        cv?.refreshControl?.tintColor = Theme.color.textPrimary
    }

    func handleError(with viewModel: ErrorViewModel) {
        guard viewModel.actions.count == 2 else { return }
        let alert = UIAlertController(
            title: viewModel.title,
            message: viewModel.body,
            preferredStyle: .alert
        )
        alert.addAction(
            .init(title: viewModel.actions[0], style: .cancel) { [weak self] _ in
                self?.presenter.handleEvent(.ErrAction(idx: 0))
            }
        )
        alert.addAction(
            .init(title: viewModel.actions[1], style: .default) { [weak self] _ in
                self?.presenter.handleEvent(.ErrAction(idx: 1))
            }
        )
        present(alert, animated: true)
    }
}
