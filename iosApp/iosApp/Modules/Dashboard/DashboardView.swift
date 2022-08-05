// Created by web3d4v on 26/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol DashboardView: AnyObject {
    func update(with viewModel: DashboardViewModel)
    func updateWallet(_ viewModel: DashboardViewModel.Wallet?, at idxPath: IndexPath)
}

final class DashboardViewController: BaseViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!

    var presenter: DashboardPresenter!

    var viewModel: DashboardViewModel?
    var animatedTransitioning: UIViewControllerAnimatedTransitioning?
    var previousYOffset: CGFloat = 0
    var lastVelocity: CGFloat = 0
    var backgroundSunsetBottomConstraint: NSLayoutConstraint?
    var backgroundGradientTopConstraint: NSLayoutConstraint?
    var backgroundGradientHeightConstraint: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        presenter.present()
    }
        
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        updateBackgroundGradientTopConstraint()
        backgroundGradientHeightConstraint?.constant = backgroundGradientHeight
    }
}

extension DashboardViewController: DashboardView {
    
    func update(with viewModel: DashboardViewModel) {
        self.viewModel = viewModel

        collectionView.reloadData()

        if let btn = navigationItem.leftBarButtonItem as? AnimatedTextBarButton {
            let nonAnimMode: AnimatedTextButton.Mode = btn.mode == .animating ? .static : .hidden
            btn.setMode(
                viewModel.shouldAnimateCardSwitcher ? .animating :  nonAnimMode,
                animated: true
            )
        }
    }

    func updateWallet(_ viewModel: DashboardViewModel.Wallet?, at idxPath: IndexPath) {
        let cell = collectionView.visibleCells.first(where: {
            collectionView.indexPath(for: $0) == idxPath
        })
        (cell as? DashboardWalletCell)?.update(with: viewModel)
    }
}

extension DashboardViewController: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        lastVelocity = scrollView.contentOffset.y - previousYOffset
        previousYOffset = scrollView.contentOffset.y
        updateBackgroundGradientTopConstraint()
    }
}

extension DashboardViewController: UIViewControllerTransitioningDelegate {

    func animationController(
        forPresented presented: UIViewController,
        presenting: UIViewController,
        source: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        
        let presentedVc = (presented as? UINavigationController)?.topViewController
        animatedTransitioning = nil

        if presentedVc?.isKind(of: AccountViewController.self) ?? false {
            let idxPath = collectionView.indexPathsForSelectedItems?.first ?? IndexPath(item: 0, section: 0)
            let cell = collectionView.cellForItem(at: idxPath)
            animatedTransitioning = CardFlipAnimatedTransitioning(
                targetView: cell ?? view
            )
        }

        return animatedTransitioning
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        let presentedVc = (dismissed as? UINavigationController)?.topViewController
        animatedTransitioning = nil

        if presentedVc?.isKind(of: AccountViewController.self) ?? false {
            let idxPath = collectionView.indexPathsForSelectedItems?.first ?? IndexPath(item: 0, section: 0)
            let cell = collectionView.cellForItem(at: idxPath)
            animatedTransitioning = CardFlipAnimatedTransitioning(
                targetView: cell ?? view,
                isPresenting: false
            )
        }

        return animatedTransitioning
    }
}

private extension DashboardViewController {
    
    func configureUI() {
        
        view.backgroundColor = Theme.colour.gradientBottom
                
        transitioningDelegate = self
                
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: "chevron.left".assetImage,
            style: .plain,
            target: self,
            action: #selector(navBarLeftActionTapped)
        )
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: "qrcode.viewfinder".assetImage,
            style: .plain,
            target: self,
            action: #selector(navBarRightActionTapped)
        )

        edgeCardsController?.delegate = self
                
        title = Localized("web3wallet").uppercased()
        addCustomBackgroundGradientView()
        configureCollectionCardsLayout()
        
        navigationController?.tabBarItem = UITabBarItem(
            title: Localized("dashboard.tab.title"),
            image: "tab_icon_dashboard".assetImage,
            tag: 0
        )

        var transform = CATransform3DIdentity
        transform.m34 = -1.0 / 500.0
        collectionView.layer.sublayerTransform = transform
    }
    
    @objc func navBarLeftActionTapped() {
        
        presenter.handle(.walletConnectionSettingsAction)
    }
    
    @objc func navBarRightActionTapped() {
        
        presenter.handle(.didScanQRCode)
    }
    
    func updateBackgroundGradientTopConstraint() {
        
        let constant: CGFloat
        if collectionView.contentOffset.y < 0 {
            constant = 0
        } else {
            constant = -collectionView.contentOffset.y
        }
        backgroundGradientTopConstraint?.constant =  constant
    }
}

extension DashboardViewController: EdgeCardsControllerDelegate {

    func edgeCardsController(
        vc: EdgeCardsController,
        didChangeTo mode: EdgeCardsController.DisplayMode
    ) {
        presenter.handle(.didInteractWithCardSwitcher)
    }
}

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

        guard let section = viewModel?.sections[indexPath.section] else {
            fatalError("No viewModel for \(indexPath) \(collectionView)")
        }
        
        let actions = section.items.actions
        if !actions.isEmpty {
            
            let cell = collectionView.dequeue(DashboardButtonsCell.self, for: indexPath)
            cell.update(with: actions, presenter: presenter)
            return cell
        } else if let notification = section.items.notifications(at: indexPath.row) {
            
            let cell = collectionView.dequeue(DashboardNotificationCell.self, for: indexPath)
            cell.update(with: notification, handler: makeNotificationHandler())
            return cell
        } else if let wallet = section.items.wallet(at: indexPath.row) {
            
            let cell = collectionView.dequeue(DashboardWalletCell.self, for: indexPath)
            cell.update(with: wallet)
            return cell
        } else if let nft = section.items.nft(at: indexPath.row) {
            
            let cell = collectionView.dequeue(DashboardNFTCell.self, for: indexPath)
            cell.update(with: nft)
            return cell
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
            return supplementaryHeaderView(kind: kind, at: indexPath)
        default:
            fatalError("Unexpected supplementary idxPath: \(indexPath) \(kind)")
        }
    }
}

extension DashboardViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let section = viewModel?.sections[indexPath.section] else { return }
        
        switch section.items {
        case .actions:
            break
        case let .notifications(notifications):
            let notification = notifications[indexPath.item]
            presenter.handle(.didTapNotification(id: notification.id))
        case let .wallets(wallets):
            let wallet = wallets[indexPath.item]
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
        guard lastVelocity > 0, (cell as? DashboardWalletCell) != nil else {
            return
        }
        cell.layer.add(
            CAAnimation.buildUp(0.05 * CGFloat(indexPath.item)),
            forKey: "transform"
        )
    }
}

private extension DashboardViewController {
    
    func supplementaryHeaderView(
        kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        
        guard let section = viewModel?.sections[indexPath.section] else {
            fatalError("no section")
        }
        
        switch section.header {
        case .none:
            fatalError("We should not configure a section header when type is none.")
        case let .balance(balance):
            let supplementary = collectionView.dequeue(
                DashboardHeaderBalanceView.self,
                for: indexPath,
                kind: kind
            )
            supplementary.update(with: balance)
            return supplementary

        case let .title(title):
            let supplementary = collectionView.dequeue(
                DashboardHeaderNameView.self,
                for: indexPath,
                kind: kind
            )
            supplementary.update(
                with: title,
                and: nil,
                handler: nil
            )
            return supplementary
            
        case let .network(network):
            
            let supplementary = collectionView.dequeue(
                DashboardHeaderNameView.self,
                for: indexPath,
                kind: kind
            )
            supplementary.update(
                with: network.name,
                and: network,
                handler: makeDashboardHeaderNameViewHandler(for: section)
            )
            return supplementary
        }
    }
    
    func makeDashboardHeaderNameViewHandler(
        for section: DashboardViewModel.Section
    ) -> DashboardHeaderNameView.Handler {
        .init(
            onMoreTapped: makeOnMoreNetworkTapped(for: section)
        )
    }
    
    func makeOnMoreNetworkTapped(
        for section: DashboardViewModel.Section
    ) -> () -> Void {
        
        {
            [weak self] in
            guard let self = self else { return }
            self.presenter.handle(.didTapEditTokens(network: section.networkId))
        }
    }
    
    func makeNotificationHandler() -> DashboardNotificationCell.Handler {
        
        let onDismiss: (String) -> Void = { [weak self] id in
            guard let self = self else { return }
            self.presenter.handle(.didTapDismissNotification(id: id))
        }
        
        return .init(
            onDismiss: onDismiss
        )
    }
}
