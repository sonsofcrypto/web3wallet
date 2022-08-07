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
    private var animatedTransitioning: UIViewControllerAnimatedTransitioning?
    private var previousYOffset: CGFloat = 0
    private var lastVelocity: CGFloat = 0
    private var backgroundView: UIScrollView?
    private var gradientView: GradientView?

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        presenter.present()
    }
        
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        backgroundView?.frame = view.bounds
        gradientView?.frame = CGRect(zeroOrigin: collectionView.contentSize)
        layoutBackgroundView()
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
        layoutBackgroundView()
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

        transitioningDelegate = self
        edgeCardsController?.delegate = self

        view.backgroundColor = Theme.colour.gradientBottom
        collectionView.layer.sublayerTransform = CATransform3D.m34(-1.0 / 500.0)

        addBackgroundView()
        configureCollectionCardsLayout()
    }

    func addBackgroundView() {
        let scrollView = UIScrollView(frame: view.bounds)
        scrollView.isUserInteractionEnabled = false
        view.insertSubview(scrollView, at: 0)
        backgroundView = scrollView

        let gradientView = GradientView(frame: collectionView.bounds)
        scrollView.addSubview(gradientView)
        self.gradientView = gradientView

        let sunsetBackground = UIImageView(
            image: "themeA-dashboard-bottom-image".assetImage
        )
    }

    func layoutBackgroundView() {
        backgroundView?.contentSize = collectionView.contentSize
        backgroundView?.contentOffset = CGPoint(
            x: collectionView.contentOffset.x,
            y: max(0, collectionView.contentOffset.y)
        )

        print("=== called", collectionView.contentOffset)
    }

    @objc func navBarLeftActionTapped() {
        presenter.handle(.walletConnectionSettingsAction)
    }
    
    @objc func navBarRightActionTapped() {
        presenter.handle(.didScanQRCode)
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

        let (cv, idxPath) = (collectionView, indexPath)

        if !section.items.actions.isEmpty {
            return cv.dequeue(DashboardButtonsCell.self, for: idxPath)
                .update(with: section.items.actions, presenter: presenter)
        } else if let notification = section.items.notifications(at: idxPath.item) {
            return cv.dequeue(DashboardNotificationCell.self, for: indexPath)
                .update(with: notification)
        } else if let wallet = section.items.wallet(at: indexPath.row) {
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
            CAAnimation.buildUp(0.005 * CGFloat(indexPath.item)),
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
            return collectionView.dequeue(
                DashboardHeaderBalanceView.self,
                for: indexPath,
                kind: kind
            ).update(with: balance)

        case let .title(title):
            return collectionView.dequeue(
                DashboardHeaderNameView.self,
                for: indexPath,
                kind: kind
            ).update(with: title, and: nil, handler: nil)
            
        case let .network(network):
            return collectionView.dequeue(
                DashboardHeaderNameView.self,
                for: indexPath,
                kind: kind
            ).update(with: network.name, and: network, handler: { [weak self] in
                self?.presenter.handle(.didTapEditTokens(network: section.networkId))
            })
        }
    }
}
