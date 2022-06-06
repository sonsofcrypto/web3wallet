// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

enum DegenWireframeDestination {
    case amms
    case cult
}

protocol DegenWireframe {
    func present()
    func navigate(to destination: DegenWireframeDestination)
}

// MARK: - DefaultDegenWireframe

final class DefaultDegenWireframe {

    private weak var parent: TabBarController!
    private weak var vc: UIViewController?
    private let degenService: DegenService
    private let ammsWireframeFactory: AMMsWireframeFactory
    private let cultProposalsWireframeFactory: CultProposalsWireframeFactory

    private weak var navigationController: NavigationController!

    init(
        parent: TabBarController,
        degenService: DegenService,
        ammsWireframeFactory: AMMsWireframeFactory,
        cultProposalsWireframeFactory: CultProposalsWireframeFactory
    ) {
        self.parent = parent
        self.degenService = degenService
        self.ammsWireframeFactory = ammsWireframeFactory
        self.cultProposalsWireframeFactory = cultProposalsWireframeFactory
    }
}

// MARK: - DegenWireframe

extension DefaultDegenWireframe: DegenWireframe {

    func present() {
        
        let vc = wireUp()
        let vcs = (parent.viewControllers ?? []) + [vc]
        parent.setViewControllers(vcs, animated: false)
    }

    func navigate(to destination: DegenWireframeDestination) {

        switch destination {
        case .amms:
            ammsWireframeFactory.makeWireframe(navigationController).present()
        case .cult:
            cultProposalsWireframeFactory.makeWireframe(
                vc ?? navigationController
            ).present()
        }
    }
}

private extension DefaultDegenWireframe {

    func wireUp() -> UIViewController {
        
        let interactor = DefaultDegenInteractor(degenService)
        let vc: DegenViewController = UIStoryboard(.main).instantiate()
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
