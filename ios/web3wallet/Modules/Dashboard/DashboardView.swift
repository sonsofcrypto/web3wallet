// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol DashboardView: AnyObject {

    func update(with viewModel: DashboardViewModel)
}

class DashboardViewController: BaseViewController {

    var presenter: DashboardPresenter!

    private var viewModel: DashboardViewModel?
    private var walletCellSize: CGSize = .zero
    private var nftsCellSize: CGSize = .zero
    private var previousYOffset: CGFloat = 0
    private var lastVelocity: CGFloat = 0
    private var animatedTransitioning: UIViewControllerAnimatedTransitioning?

    @IBOutlet weak var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        presenter?.present()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let length = (view.bounds.width - Global.padding * 2 - Constant.spacing) / 2
        walletCellSize = CGSize(width: length, height: length)
        nftsCellSize = CGSize(
            width: view.bounds.width - Global.padding * 2,
            height: length)
    }

    // MARK: - Actions

    @IBAction func receiveAction(_ sender: Any) {
        
        presentUnderConstructionAlert()
    }

    @IBAction func sendAction(_ sender: Any) {
        presenter.handle(.sendAction)
    }

    @IBAction func tradeAction(_ sender: Any) {
        presenter.handle(.tradeAction)
    }

    @IBAction func walletConnectionSettingsAction(_ sender: Any) {
        presenter.handle(.walletConnectionSettingsAction)
    }

}

// MARK: - DashboardView

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
        let pctLabel = navigationItem.rightBarButtonItem?.customView as? UILabel
        pctLabel?.text = viewModel.header.pct
        pctLabel?.textColor = viewModel.header.pctUp
            ? Theme.current.green
            : Theme.current.red
    }
}

// MARK: - UICollectionViewDataSource

extension DashboardViewController: UICollectionViewDataSource {

    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel?.sections.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let section = viewModel?.sections[section] else {
            return 0
        }
        return section.wallets.count + (section.nfts.count > 0 ? 1 : 0)
    }
    

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let section = viewModel?.sections[indexPath.section] else {
            fatalError("No viewModel for \(indexPath) \(collectionView)")
        }

        if indexPath.item >= section.wallets.count {
            let cell = collectionView.dequeue(DashboardNFTsCell.self, for: indexPath)
            cell.update(with: section.nfts)
            return cell
        } else {
            let cell = collectionView.dequeue(DashboardWalletCell.self, for: indexPath)
            cell.update(with: section.wallets[indexPath.item])
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            switch indexPath.section {
            case 0:
                let supplementary = collectionView.dequeue(
                    DashboardHeaderView.self,
                    for: indexPath,
                    kind: kind
                )
                supplementary.update(with: viewModel?.header)
                addActions(for: supplementary)
                return supplementary
            default:
                let supplementary = collectionView.dequeue(
                    DashboardSectionHeaderView.self,
                    for: indexPath,
                    kind: kind
                )
                supplementary.update(with: viewModel?.sections[indexPath.section])
                return supplementary
            }
        }

        fatalError("Unexpected supplementary idxPath: \(indexPath) \(kind)")
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension DashboardViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.item >= viewModel?.sections[indexPath.section].wallets.count ?? 0 {
            return nftsCellSize
        }

        return walletCellSize
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        CGSize(
            width: view.bounds.width - Global.padding * 2,
            height: section == 0 ? Constant.headerHeight : Constant.sectionHeaderHeight
        )
    }
}

// MARK: - UICollectionViewDelegate

extension DashboardViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let section = viewModel?.sections[indexPath.section]
        if indexPath.item < section?.wallets.count ?? 0 {
            presenter.handle(.didSelectWallet(idx: indexPath.item))
        }
        // TODO: implement NFT selection
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
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

// MARK: - UIScrollViewDelegate

extension DashboardViewController: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        lastVelocity = scrollView.contentOffset.y - previousYOffset
        previousYOffset = scrollView.contentOffset.y
    }
}

// MARK: - UIViewControllerTransitioningDelegate

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

// MARK: - Configure UI

extension DashboardViewController {
    
    func configureUI() {
        title = Localized("dashboard")
        (view as? GradientView)?.colors = [
            Theme.current.background,
            Theme.current.backgroundDark
        ]

        tabBarItem = UITabBarItem(
            title: Localized("dashboard.tab.title"),
            image: UIImage(named: "tab_icon_dashboard"),
            tag: 0
        )

        collectionView.register(
            DashboardSectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "\(DashboardSectionHeaderView.self)"
        )

        navigationItem.rightBarButtonItem = UIBarButtonItem.glowLabel()
        let btn = AnimatedTextBarButton(
            with: [
                "Wallet",
                "Network"
            ],
            mode: .static,
            target: self,
            action: #selector(walletConnectionSettingsAction(_:))
        )
        btn.setMode(.hidden, animated: true)
        navigationItem.leftBarButtonItem = btn

        transitioningDelegate = self

        var insets = collectionView.contentInset
        insets.bottom += Global.padding
        collectionView.contentInset = insets

        var transform = CATransform3DIdentity
        transform.m34 = -1.0 / 500.0
        collectionView.layer.sublayerTransform = transform

        let overScrollView = (collectionView as? CollectionView)
        overScrollView?.overScrollView.image = UIImage(named: "overscroll_pepe")

        edgeCardsController?.delegate = self
    }
}

// MARK: -

extension DashboardViewController: EdgeCardsControllerDelegate {

    func edgeCardsController(
        vc: EdgeCardsController,
        didChangeTo mode: EdgeCardsController.DisplayMode
    ) {
        presenter.handle(.didInteractWithCardSwitcher)
    }
}

// MARK: - Utilities

private extension DashboardViewController {

    func addActions(for supplementary: DashboardHeaderView) {
        supplementary.receiveButton.addTarget(
            self,
            action: #selector(receiveAction(_:)),
            for: .touchUpInside
        )
        supplementary.sendButton.addTarget(
            self,
            action: #selector(sendAction(_:)),
            for: .touchUpInside
        )
        supplementary.tradeButton.addTarget(
            self,
            action: #selector(tradeAction(_:)),
            for: .touchUpInside
        )
    }
}

// MARK: - Constant

extension DashboardViewController {

    enum Constant {
        static let headerHeight: CGFloat = 211
        static let sectionHeaderHeight: CGFloat = 59
        static let spacing: CGFloat = 17
    }
}
