// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

enum DegenWireframeDestination {
    case swap
    case cult
}

protocol DegenWireframe {
    func present()
    func navigate(to destination: DegenWireframeDestination)
}

final class DefaultDegenWireframe {

    private weak var parent: TabBarController!
    private let degenService: DegenService
    private let cultProposalsWireframeFactory: CultProposalsWireframeFactory

    private weak var navigationController: NavigationController!

    init(
        parent: TabBarController,
        cultProposalsWireframeFactory: CultProposalsWireframeFactory,
        degenService: DegenService
    ) {
        
        self.parent = parent
        self.cultProposalsWireframeFactory = cultProposalsWireframeFactory
        self.degenService = degenService
    }
}

extension DefaultDegenWireframe: DegenWireframe {

    func present() {
        
        let vc = wireUp()
        let vcs = (parent.viewControllers ?? []) + [vc]
        parent.setViewControllers(vcs, animated: false)
    }

    func navigate(to destination: DegenWireframeDestination) {

        switch destination {
        case .swap:
            break
        case .cult:
            cultProposalsWireframeFactory.makeWireframe(
                navigationController
            ).present()
        }
    }
}

private extension DefaultDegenWireframe {

    func wireUp() -> UIViewController {
        
        let interactor = DefaultDegenInteractor(degenService)
        let vc: DegenViewController = UIStoryboard(.degen).instantiate()
        let presenter = DefaultDegenPresenter(
            view: vc,
            interactor: interactor,
            wireframe: self
        )

        vc.presenter = presenter
        
        let navigationController = NavigationController(rootViewController: vc)
        self.navigationController = navigationController
        
        navigationController.tabBarItem = UITabBarItem(
            title: Localized("degen"),
            image: UIImage(named: "tab_icon_degen"),
            tag: 1
        )
        
        return navigationController
    }
}
