// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

enum DegenWireframeDestination {
    
    case swap
    case cult
    case comingSoon
}

protocol DegenWireframe {
    func present()
    func navigate(to destination: DegenWireframeDestination)
}

final class DefaultDegenWireframe {

    private weak var parent: TabBarController!
    private let tokenSwapWireframeFactory: TokenSwapWireframeFactory
    private let cultProposalsWireframeFactory: CultProposalsWireframeFactory
    private let alertWireframeFactory: AlertWireframeFactory
    private let degenService: DegenService

    private weak var navigationController: NavigationController!

    init(
        parent: TabBarController,
        tokenSwapWireframeFactory: TokenSwapWireframeFactory,
        cultProposalsWireframeFactory: CultProposalsWireframeFactory,
        alertWireframeFactory: AlertWireframeFactory,
        degenService: DegenService
    ) {
        
        self.parent = parent
        self.tokenSwapWireframeFactory = tokenSwapWireframeFactory
        self.cultProposalsWireframeFactory = cultProposalsWireframeFactory
        self.alertWireframeFactory = alertWireframeFactory
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
            tokenSwapWireframeFactory.makeWireframe(
                presentingIn: navigationController,
                context: .init(
                    presentationStyle: .present,
                    tokenFrom: nil,
                    tokenTo: nil
                )
            ).present()
        case .cult:
            cultProposalsWireframeFactory.makeWireframe(
                navigationController
            ).present()
        case .comingSoon:
            let wireframe = alertWireframeFactory.makeWireframe(
                navigationController,
                context: .underConstructionAlert()
            )
            wireframe.present()
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
            image: "tab_icon_degen".assetImage,
            tag: 1
        )
        
        return navigationController
    }
}
