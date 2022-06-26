// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol DashboardView: AnyObject {

    func update(with viewModel: DashboardViewModel)
}

final class DashboardViewController: BaseViewController {

    var presenter: DashboardPresenter!

    private (set) var viewModel: DashboardViewModel?
    private var animatedTransitioning: UIViewControllerAnimatedTransitioning?

    // ThemeOG
    @IBOutlet weak var collectionView: UICollectionView!
    private var previousYOffset: CGFloat = 0
    private (set) var lastVelocity: CGFloat = 0

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        configureUI()
        
        presenter.present()
    }
    
    override func navBarRightBarActionTapped() {
        
        presenter.handle(.didTapEditTokens)
    }
}

private extension DashboardViewController {
    
    @IBAction func walletConnectionSettingsAction(_ sender: Any) {
        
        presenter.handle(.walletConnectionSettingsAction)
    }
}

extension DashboardViewController: DashboardView {

    func update(with viewModel: DashboardViewModel) {
        
        self.viewModel = viewModel
        
        updateThemeOG()
        
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
        
        title = Localized("dashboard")
        (view as? GradientView)?.colors = [
            Theme.color.background,
            Theme.color.backgroundDark
        ]

        navigationController?.tabBarItem = UITabBarItem(
            title: Localized("dashboard.tab.title"),
            image: UIImage(named: "tab_icon_dashboard"),
            tag: 0
        )

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
        
        configureRightBarButtonItemAction(icon: "list_settings_icon", tint: Theme.color.red)

        transitioningDelegate = self

        edgeCardsController?.delegate = self
        
        configureThemeOG()
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

extension DashboardViewController {

    enum Constant {
        
        static let headerHeight: CGFloat = 211
        static let sectionHeaderHeight: CGFloat = 59
        static let spacing: CGFloat = 17
    }
}
