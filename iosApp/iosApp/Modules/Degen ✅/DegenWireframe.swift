// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3lib

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
    private weak var parent: UIViewController?
    private let tokenSwapWireframeFactory: TokenSwapWireframeFactory
    private let cultProposalsWireframeFactory: CultProposalsWireframeFactory
    private let alertWireframeFactory: AlertWireframeFactory
    private let degenService: DegenService
    private let networksService: NetworksService

    private weak var vc: UIViewController?

    init(
        _ parent: UIViewController,
        tokenSwapWireframeFactory: TokenSwapWireframeFactory,
        cultProposalsWireframeFactory: CultProposalsWireframeFactory,
        alertWireframeFactory: AlertWireframeFactory,
        degenService: DegenService,
        networksService: NetworksService
    ) {
        
        self.parent = parent
        self.tokenSwapWireframeFactory = tokenSwapWireframeFactory
        self.cultProposalsWireframeFactory = cultProposalsWireframeFactory
        self.alertWireframeFactory = alertWireframeFactory
        self.degenService = degenService
        self.networksService = networksService
    }
}

extension DefaultDegenWireframe: DegenWireframe {

    func present() {
        let vc = wireUp()
        if let tabVc = parent as? UITabBarController {
            let vcs = (tabVc.viewControllers ?? []) + [vc]
            tabVc.setViewControllers(vcs, animated: false)
        } else {
            parent?.show(vc, sender: self)
        }
    }

    func navigate(to destination: DegenWireframeDestination) {
        switch destination {
        case .swap:
            guard let network = networksService.network else { return }
            tokenSwapWireframeFactory.make(
                vc,
                context: .init(network: network, currencyFrom: nil, currencyTo: nil)
            ).present()
        case .cult:
            cultProposalsWireframeFactory.make(vc).present()
        case .comingSoon:
            alertWireframeFactory.make(
                vc,
                context: .underConstructionAlert()
            ).present()
        }
    }
}

private extension DefaultDegenWireframe {

    func wireUp() -> UIViewController {
        let interactor = DefaultDegenInteractor(
            degenService,
            networksService: networksService
        )
        let vc: DegenViewController = UIStoryboard(.degen).instantiate()
        let presenter = DefaultDegenPresenter(
            view: vc,
            interactor: interactor,
            wireframe: self
        )
        vc.presenter = presenter
        let nc = NavigationController(rootViewController: vc)
        nc.tabBarItem = UITabBarItem(
            title: Localized("degen"),
            image: "tab_icon_degen".assetImage,
            tag: 1
        )
        self.vc = nc
        return nc
    }
}
