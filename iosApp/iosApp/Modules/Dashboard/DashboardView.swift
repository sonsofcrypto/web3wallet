// Created by web3d4v on 26/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol DashboardView: AnyObject {
    func update(with viewModel: DashboardViewModel)
}

final class DashboardViewController: BaseViewController {
    @IBOutlet weak var collectionView: UICollectionView!

    var presenter: DashboardPresenter!

    var viewModel: DashboardViewModel?
    private var previousYOffset: CGFloat = 0
    private var lastVelocity: CGFloat = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        presenter.present()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        (view as? DashboardBackgroundView)?.layoutForCollectionView(collectionView)
    }

    deinit {
        presenter.releaseResources()
    }
}

extension DashboardViewController: DashboardView {
    
    func update(with viewModel: DashboardViewModel) {
        if collectionView.refreshControl?.isRefreshing ?? false {
            collectionView.refreshControl?.endRefreshing()
        }
        if self.viewModel?.sections.count != viewModel.sections.count {
            self.viewModel = viewModel
            collectionView.reloadData()
            return
        }
        var sectionsToReload = [Int]()
        var sectionsToUpdate = [Int]()
        let cv = collectionView!
        let header = UICollectionView.elementKindSectionHeader
        for (idx, section) in viewModel.sections.enumerated() {
            let prevSection = self.viewModel?.sections[idx]
            if section.items.count != prevSection?.items.count
               || !section.items.isSameKind(prevSection?.items) {
                sectionsToReload.append(idx)
            } else {
                sectionsToUpdate.append(idx)
            }
        }
        self.viewModel = viewModel
        if !sectionsToReload.isEmpty {
            cv.performBatchUpdates { cv.reloadSections(IndexSet(sectionsToReload)) }
        }
        cv.visibleCells.forEach {
            if let idxPath = cv.indexPath(for: $0),
                sectionsToUpdate.contains(idxPath.section) {
                let items = viewModel.sections[idxPath.section].items
                update(cell: $0, idx: idxPath.item, items: items)
            }
        }

        // TODO: Refactor once viewModel clean up is done
        cv.indexPathsForVisibleSupplementaryElements(ofKind: header).forEach {
            let view = cv.supplementaryView(forElementKind: header, at: $0)
            switch viewModel.header(at: $0.section) {
            case let .balance(balance):
                (view as? DashboardHeaderBalanceView)?.update(with: balance)
            case let .title(title):
                (view as? DashboardHeaderNameView)?.update(with: title, and: nil, handler: nil)
            case let .network(network):
                (view as? DashboardHeaderNameView)?.update(
                    with: network.name,
                    and: network,
                handler: { [weak self] in
                        self?.presenter.handle(.didTapEditTokens(network: network.id))
                    }
                )
            default: ()
            }
        }
    }

    func updateWallet(
        _ viewModel: DashboardViewModel.Wallet?,
        at idxPath: IndexPath
    ) {
        let cell = collectionView.visibleCells.first(where: {
            collectionView.indexPath(for: $0) == idxPath
        })
        let _ = (cell as? DashboardWalletCell)?.update(with: viewModel)
    }

    func update(
        cell: UICollectionViewCell,
        idx: Int,
        items: DashboardViewModel.Section.Items
    ) {
        let _ = (cell as? DashboardButtonsCell)?.update(with: items.buttons, presenter: presenter)
        let _ = (cell as? DashboardActionCell)?.update(with: items.actions(at: idx))
        let _ = (cell as? DashboardWalletCell)?.update(with: items.wallet(at: idx))
        let _ = (cell as? DashboardTableWalletCell)?.update(with: items.wallet(at: idx))
        let _ = (cell as? DashboardNFTCell)?.update(with: items.nft(at: idx))

    }
}

// MARK: - UICollectionViewDataSource

extension DashboardViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        viewModel?.sections.count ?? 0
    }

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        guard let section = viewModel?.sections[section] else { return 0 }
        guard section.items.count > 4 else { return section.items.count }
        return section.isCollapsed ? 4 : section.items.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let section = viewModel?.sections[safe: indexPath.section] else {
            fatalError("No viewModel for \(indexPath) \(collectionView)")
        }
        let (cv, idxPath) = (collectionView, indexPath)
        if !section.items.buttons.isEmpty {
            return cv.dequeue(DashboardButtonsCell.self, for: idxPath)
                .update(with: section.items.buttons, presenter: presenter)
        } else if let action = section.items.actions(at: idxPath.item) {
            return cv.dequeue(DashboardActionCell.self, for: indexPath)
                .update(with: action)
        } else if let wallet = section.items.wallet(at: indexPath.row) {
            if Theme.type.isThemeIOS {
                let isLast = (section.items.count - 1) == indexPath.item
                return cv.dequeue(DashboardTableWalletCell.self, for: indexPath)
                    .update(with: wallet, showBottomSeparator: !isLast)
            }
            return cv.dequeue(DashboardWalletCell.self, for: indexPath)
                    .update(with: wallet)
        } else if let nft = section.items.nft(at: indexPath.row) {
            return cv.dequeue(DashboardNFTCell.self, for: indexPath)
                .update(with: nft)
        } else {
            fatalError("No viewModel for \(indexPath) \(collectionView)")
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            guard let section = viewModel?.sections[indexPath.section] else {
                fatalError("Unexpected header idxPath: \(indexPath) \(kind)")
            }
            return headerView(kind: kind, at: indexPath, section: section)
        default:
            fatalError("Unexpected supplementary idxPath: \(indexPath) \(kind)")
        }
    }

    func headerView(
        kind: String,
        at idxPath: IndexPath,
        section: DashboardViewModel.Section
    ) -> UICollectionReusableView {
        switch section.header {
        case let .balance(balance):
            return collectionView.dequeue(DashboardHeaderBalanceView.self,
                for: idxPath,
                kind: kind
            ).update(with: balance)
        case let .title(title):
            return collectionView.dequeue(
                DashboardHeaderNameView.self,
                for: idxPath,
                kind: kind
            ).update(with: title, and: nil, handler: nil)
        case let .network(network):
            return collectionView.dequeue(
                DashboardHeaderNameView.self,
                for: idxPath,
                kind: kind
            ).update(with: network.name, and: network) { [weak self] in
                self?.presenter.handle(.didTapEditTokens(network: section.networkId))
            }
        case .none:
            fatalError("Should not configure a section header when type none.")
        }
    }
}

// MARK: - UICollectionViewDelegate

extension DashboardViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let section = viewModel?.sections[indexPath.section] else { return }
        switch section.items {
        case .buttons:
            break
        case .actions:
            presenter.handle(.didTapAction(idx: indexPath.item))
        case .wallets:
            presenter.handle(
                .didSelectWallet(
                    networkIdx: indexPath.section - 2,
                    currencyIdx: indexPath.item
                )
            )
        case let .nfts(nfts):
            let nft = nfts[indexPath.item]
            nft.onSelected()
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        let cv = collectionView
        guard lastVelocity > 0, (cell as? DashboardWalletCell) != nil,
              (cv.isTracking || cv.isDragging || cv.isDecelerating)  else {
            return
        }
        cell.layer.add(
            CAAnimation.buildUp(0.005 * CGFloat(indexPath.item)),
            forKey: "transform"
        )
    }
}

// MARK: - UIScrollViewDelegate

extension DashboardViewController: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        lastVelocity = scrollView.contentOffset.y - previousYOffset
        previousYOffset = scrollView.contentOffset.y
        (view as? DashboardBackgroundView)?.layoutForCollectionView(collectionView)
    }
}

// MARK: - Config


private extension DashboardViewController {

    func configureUI() {
        title = Localized("web3wallet").uppercased()
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            imageName: "chevron.left",
            target: self,
            action: #selector(navBarLeftActionTapped)
        )
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            imageName: "qrcode.viewfinder",
            target: self,
            action: #selector(navBarRightActionTapped)
        )
        navigationController?.tabBarItem = UITabBarItem(
            title: Localized("dashboard.tab.title"),
            image: "tab_icon_dashboard".assetImage,
            tag: 0
        )
        edgeCardsController?.delegate = self
        collectionView.contentInset = UIEdgeInsets.with(bottom: 180)
        collectionView.register(DashboardHeaderNameView.self, kind: .header)
        collectionView.setCollectionViewLayout(compositionalLayout(), animated: false)
        collectionView.refreshControl = UIRefreshControl()
        collectionView.backgroundView = nil
        collectionView.layer.sublayerTransform = CATransform3D.m34(-1.0 / 500.0)
        collectionView.refreshControl?.tintColor = Theme.colour.activityIndicator
        collectionView.refreshControl?.addTarget(self, action: #selector(didPullToRefresh(_:)), for: .valueChanged)
    }
    
    @objc func didPullToRefresh(_ sender: Any) {
        presenter.handle(.pullDownToRefresh)
    }

    @objc func navBarLeftActionTapped() {
        presenter.handle(.walletConnectionSettingsAction)
    }

    @objc func navBarRightActionTapped() {
        presenter.handle(.didScanQRCode)
    }

    func compositionalLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] idx, env in
            guard let section = self?.viewModel?.sections[idx] else { return nil }
            switch section.items {
            case .buttons:
                return self?.buttonsCollectionLayoutSection()
            case .actions:
                return self?.notificationsCollectionLayoutSection()
            case .nfts:
                return self?.nftsCollectionLayoutSection()
            case .wallets:
                return Theme.type.isThemeIOS
                    ? self?.walletsTableCollectionLayoutSection()
                    : self?.walletsCollectionLayoutSection()
            }
        }
        // TODO: Decouple this
        if Theme.type.isThemeIOS {
            layout.register(
                DgenCellBackgroundSupplementaryView.self,
                forDecorationViewOfKind: "background"
            )
        }
        return layout
    }

    func buttonsCollectionLayoutSection() -> NSCollectionLayoutSection {
        let h = Theme.constant.buttonDashboardActionHeight
        let group = NSCollectionLayoutGroup.horizontal(
            .fractional(estimatedH: 100),
            items: [.init(layoutSize: .fractional(estimatedH: h))]
        )
        let section = NSCollectionLayoutSection(group: group, insets: .padding)
        let headerItem = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: .fractional(estimatedH: 50),
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        section.boundarySupplementaryItems = [headerItem]
        section.orthogonalScrollingBehavior = .none
        return section
    }

    func notificationsCollectionLayoutSection() -> NSCollectionLayoutSection {
        let width = floor((view.bounds.width - Theme.constant.padding * 3)  / 2)
        let group = NSCollectionLayoutGroup.horizontal(
            .estimated(view.bounds.width * 3, height: 64),
            items: [.init(layoutSize: .absolute(width, estimatedH: 64))]
        )
        let section = NSCollectionLayoutSection(group: group, insets: .padding)
        section.interGroupSpacing = Theme.constant.padding
        section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
        return section
    }

    func walletsCollectionLayoutSection() -> NSCollectionLayoutSection {
        let width = floor((view.bounds.width - Theme.constant.padding * 3) / 2)
        let height = round(width * 0.95)
        let group = NSCollectionLayoutGroup.horizontal(
            .fractional(absoluteH: height),
            items: [.init(.absolute(width, height: height))]
        )
        group.interItemSpacing = .fixed(Theme.constant.padding)
        let section = NSCollectionLayoutSection(group: group, insets: .padding)
        let headerItem = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: .fractional(estimatedH: 100),
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        section.interGroupSpacing = Theme.constant.padding
        section.boundarySupplementaryItems = [headerItem]
        return section
    }

    func walletsTableCollectionLayoutSection() -> NSCollectionLayoutSection {
        let group = NSCollectionLayoutGroup.horizontal(
            .fractional(absoluteH: 64),
            items: [.init(.fractional(absoluteH: 64))]
        )
        let section = NSCollectionLayoutSection(group: group, insets: .padding)
        let headerItem = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: .fractional(estimatedH: 100),
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        let backgroundItem = NSCollectionLayoutDecorationItem.background(
            elementKind: "background"
        )
        backgroundItem.contentInsets = .padding(top: Theme.constant.padding * 3)
        section.decorationItems = [backgroundItem]
        section.boundarySupplementaryItems = [headerItem]
        return section
    }

    func nftsCollectionLayoutSection() -> NSCollectionLayoutSection {
        let width = floor((view.bounds.width - Theme.constant.padding * 3) / 2)
        let group = NSCollectionLayoutGroup.horizontal(
            .estimated(view.bounds.width * 3, height: width),
            items: [.init(.absolute(width, height: width))]
        )
        group.interItemSpacing = .fixed(Theme.constant.padding)
        let section = NSCollectionLayoutSection(group: group, insets: .padding)
        let headerItem = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: .fractional(estimatedH: 100),
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        section.interGroupSpacing = Theme.constant.padding
        section.boundarySupplementaryItems = [headerItem]
        section.orthogonalScrollingBehavior = .continuous
        return section
    }
}

// MARK: - EdgeCardsControllerDelegate

extension DashboardViewController: EdgeCardsControllerDelegate {
    func edgeCardsController(
        vc: EdgeCardsController,
        didChangeTo mode: EdgeCardsController.DisplayMode
    ) {
        presenter.handle(.didInteractWithCardSwitcher)
    }
}

extension DashboardViewController: TargetViewTransitionDatasource {

    func targetView() -> UIView {
        guard let idxPath = collectionView.indexPathsForSelectedItems?.first else {
            return view
        }
        return collectionView.cellForItem(at: idxPath) ?? view
    }
}
