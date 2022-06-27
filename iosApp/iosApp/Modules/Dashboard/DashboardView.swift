// Created by web3d4v on 26/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol DashboardView: AnyObject {

    func update(with viewModel: DashboardViewModel)
}

final class DashboardViewController: BaseViewController {
    
    var presenter: DashboardPresenter!
    var themeProvider: ThemeProvider!

    private (set) var viewModel: DashboardViewModel?
    private var animatedTransitioning: UIViewControllerAnimatedTransitioning?
    private var previousYOffset: CGFloat = 0
    private (set) var lastVelocity: CGFloat = 0
    
    private var backgroundSunsetBottomConstraint: NSLayoutConstraint?
    private var backgroundGradientTopConstraint: NSLayoutConstraint?
    private var backgroundGradientViewOffset: CGFloat = 0
    private var backgroundGradientHeightConstraint: NSLayoutConstraint?

    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        configureUI()
        
        presenter.present()
    }
    
    override func navBarLeftActionTapped() {
        presenter.handle(.walletConnectionSettingsAction)
    }
    
    override func navBarRightActionTapped() {
        
        switch theme {
            
        case .themeOG:
            presenter.handle(.didTapEditTokens)
            
        case .themeHome:
//            themeProvider.flipTheme()
            presenter.handle(.didTapEditTokens)
            //presenter.handle(.didScanQRCode)
        }
    }
    
    override func viewWillLayoutSubviews() {
        
        super.viewWillLayoutSubviews()
        
        backgroundGradientTopConstraint?.constant = -(collectionView.contentOffset.y + backgroundGradientViewOffset)
        backgroundGradientHeightConstraint?.constant = backgroundGradientHeight
        backgroundSunsetBottomConstraint?.constant = -(collectionView.contentOffset.y * 0.1 + sunsetBottomConstraintOffset)
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
        
        backgroundGradientTopConstraint?.constant = -(scrollView.contentOffset.y + backgroundGradientViewOffset)
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
                
        transitioningDelegate = self

        backgroundGradientViewOffset = view.frame.size.height
        
        edgeCardsController?.delegate = self
                
        collectionView.register(
            DashboardHeaderBalanceView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "\(DashboardHeaderBalanceView.self)"
        )
        collectionView.register(
            DashboardHeaderNameView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "\(DashboardHeaderNameView.self)"
        )
        collectionView.setCollectionViewLayout(
            makeCompositionalLayout(),
            animated: false
        )
        
        var insets = collectionView.contentInset
        insets.bottom += Global.padding
        collectionView.contentInset = insets

        var transform = CATransform3DIdentity
        transform.m34 = -1.0 / 500.0
        collectionView.layer.sublayerTransform = transform
                
        switch themeProvider.current {
            
        case .themeOG:
            configureThemeOG()
            
        case .themeHome:
            configureThemeHome()
            // Add custom background view
            addCustomBackgroundGradientView()
        }
        
        navigationController?.tabBarItem = UITabBarItem(
            title: Localized("dashboard.tab.title"),
            image: UIImage(named: "tab_icon_dashboard"),
            tag: 0
        )
    }
    
    func makeCompositionalLayout() -> UICollectionViewCompositionalLayout {
        
        UICollectionViewCompositionalLayout { [weak self] sectionIndex, environment in
            
            guard let self = self else { return nil }
            
            guard let viewModel = self.viewModel else { return nil }
            
            if sectionIndex == 0 {
                
                return self.makeButtonsCollectionLayoutSection()
            } else if sectionIndex == viewModel.sections.count - 1 {
                
                return self.makeNFTsCollectionLayoutSection()
            } else {
                
                return self.makeWalletsCollectionLayoutSection()
            }
        }
    }
    
    func makeButtonsCollectionLayoutSection() -> NSCollectionLayoutSection {
        
        let inset: CGFloat = theme.padding * 0.5
        
        // Item
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalHeight(1)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: inset, bottom: 0, trailing: inset)
        
        // Group
        let screenWidth: CGFloat = (view.bounds.width - theme.padding)
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .absolute(screenWidth),
            heightDimension: .absolute(UIButton.Web3WalletButtonStyle.primary.height + theme.padding)
        )
        let outerGroup = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize, subitems: [item]
        )
        
        // Section
        let sectionInset: CGFloat = theme.padding * 0.5
        let section = NSCollectionLayoutSection(group: outerGroup)
        section.contentInsets = .init(
            top: sectionInset,
            leading: sectionInset,
            bottom: sectionInset * 4,
            trailing: sectionInset
        )
        
        let headerItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100))
        let headerItem = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerItemSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        section.boundarySupplementaryItems = [headerItem]
        section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
                
        return section
    }
    
    func makeWalletsCollectionLayoutSection() -> NSCollectionLayoutSection {
        
        let inset: CGFloat = theme.padding * 0.5
        
        // Item
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: inset, leading: inset, bottom: inset, trailing: inset)
        
        // Group
        let screenWidth: CGFloat = (view.bounds.width - theme.padding * 0.5)
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .absolute(screenWidth),
            heightDimension: .absolute(screenWidth * 0.425)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        // Section
        let sectionInset: CGFloat = theme.padding * 0.5
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(
            top: sectionInset,
            leading: sectionInset,
            bottom: sectionInset * 3,
            trailing: sectionInset
        )
        
        let headerItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100))
        let headerItem = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerItemSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        section.boundarySupplementaryItems = [headerItem]
        
        return section
    }
    
    func makeNFTsCollectionLayoutSection() -> NSCollectionLayoutSection {
        
        let inset: CGFloat = theme.padding * 0.5
        
        // Item
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.5),
            heightDimension: .fractionalWidth(0.5)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: inset, leading: inset, bottom: inset, trailing: inset)
        
        // Group
        let screenWidth: CGFloat = (view.bounds.width - theme.padding)
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .absolute(screenWidth),
            heightDimension: .absolute(screenWidth * 0.5)
        )
        let outerGroup = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize, subitems: [item]
        )
        
        // Section
        let sectionInset: CGFloat = theme.padding * 0.5
        let section = NSCollectionLayoutSection(group: outerGroup)
        section.contentInsets = .init(
            top: sectionInset,
            leading: sectionInset,
            bottom: sectionInset + collectionView.frame.size.width * 0.475,
            trailing: sectionInset
        )
        
        let headerItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100))
        let headerItem = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerItemSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        section.boundarySupplementaryItems = [headerItem]
        section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
                
        return section
    }
    
    func addCustomBackgroundGradientView() {
        
        // 1 - Add gradient
        let backgroundGradient = GradientView()
        backgroundGradient.isDashboard = true
        view.insertSubview(backgroundGradient, at: 0)
        
        backgroundGradient.translatesAutoresizingMaskIntoConstraints = false
        
        let topConstraint = backgroundGradient.topAnchor.constraint(
            equalTo: view.topAnchor
        )
        self.backgroundGradientTopConstraint = topConstraint
        topConstraint.isActive = true

        backgroundGradient.leadingAnchor.constraint(
            equalTo: view.leadingAnchor
        ).isActive = true

        backgroundGradient.trailingAnchor.constraint(
            equalTo: view.trailingAnchor
        ).isActive = true

        let heightConstraint = backgroundGradient.heightAnchor.constraint(
            equalToConstant: backgroundGradientHeight
        )
        self.backgroundGradientHeightConstraint = heightConstraint
        heightConstraint.isActive = true
        
        // 2 - Add sunset image
        let sunsetBackground = UIImageView(
            image: UIImage(named: "sun_and_palms")
        )
        view.insertSubview(sunsetBackground, at: 1)
        
        sunsetBackground.translatesAutoresizingMaskIntoConstraints = false
        
        let bottomConstraint = sunsetBackground.bottomAnchor.constraint(
            equalTo: backgroundGradient.bottomAnchor,
            constant: sunsetBottomConstraintOffset
        )
        self.backgroundSunsetBottomConstraint = bottomConstraint
        bottomConstraint.isActive = true

        sunsetBackground.leadingAnchor.constraint(
            equalTo: view.leadingAnchor,
            constant: 16
        ).isActive = true

        view.trailingAnchor.constraint(
            equalTo: sunsetBackground.trailingAnchor,
            constant: 16
        ).isActive = true
        
        sunsetBackground.heightAnchor.constraint(
            equalTo: sunsetBackground.widthAnchor,
            multiplier: 0.7
        ).isActive = true
    }
    
    var backgroundGradientHeight: CGFloat {
        
        let offset = backgroundGradientViewOffset * 2
        
        if collectionView.frame.size.height > collectionView.contentSize.height {
            
            return collectionView.frame.size.height + offset
        } else {
            
            return collectionView.contentSize.height + offset
        }
    }
    
    var sunsetBottomConstraintOffset: CGFloat {
        
        backgroundGradientViewOffset * 0.90
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
        guard kind == UICollectionView.elementKindSectionHeader else {
            
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

final class BackgroundSupplementaryView: UICollectionReusableView {
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        layer.cornerRadius = 8
        
        backgroundColor = UIColor(white: 0.85, alpha: 1)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
            supplementary.update(with: section)
            return supplementary
        }
    }
}
