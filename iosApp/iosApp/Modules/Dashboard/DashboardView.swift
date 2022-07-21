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

    // NOTE: Ideally all this should be private but because we split the code in separate
    // extensions this needs to be internal unfortunately (hoping swift one day fixes this).
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
            image: .init(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(navBarLeftActionTapped)
        )
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: .init(systemName: "qrcode.viewfinder"),
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
            image: UIImage(named: "tab_icon_dashboard"),
            tag: 0
        )
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

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        guard let section = viewModel?.sections[section] else { return 0 }
        
        guard section.items.count > 4 else { return section.items.count }
        
        return (section.isCollapsed ?? false) ? 4 : section.items.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {

        guard let section = viewModel?.sections[indexPath.section] else {
            
            fatalError("No viewModel for \(indexPath) \(collectionView)")
        }
        
        let actions = section.items.actions()
        if !actions.isEmpty {
            
            let cell = collectionView.dequeue(DashboardButtonsCell.self, for: indexPath)
            cell.update(with: actions, presenter: presenter)
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
        case let .wallets(wallets):
            let wallet = wallets[indexPath.item]
            presenter.handle(.didSelectWallet(network: section.name, symbol: wallet.ticker))
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
        
        guard lastVelocity > 0 else {
            return
        }

        let rotation = CATransform3DMakeRotation(-3.13 / 2, 1, 0, 0)
        let anim = CABasicAnimation(keyPath: "transform")
        anim.fromValue = CATransform3DScale(rotation, 0.5, 0.5, 0)
        anim.toValue = CATransform3DIdentity
        anim.duration = 0.3
        anim.isRemovedOnCompletion = true
        anim.fillMode = .both
        anim.timingFunction = CAMediaTimingFunction(name: .easeOut)
        anim.beginTime = CACurrentMediaTime() + 0.05 * CGFloat(indexPath.item);
        cell.layer.add(anim, forKey: "transform")
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
        
        switch indexPath.section {
            
        case 0:
            let supplementary = collectionView.dequeue(
                DashboardHeaderBalanceView.self,
                for: indexPath,
                kind: kind
            )
            supplementary.update(with: section)
            return supplementary
            
        default:
            
            let supplementary = collectionView.dequeue(
                DashboardHeaderNameView.self,
                for: indexPath,
                kind: kind
            )
            supplementary.update(with: section, presenter: presenter)
            return supplementary
        }
    }
}
