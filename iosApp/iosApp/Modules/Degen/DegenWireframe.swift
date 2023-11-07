// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

final class DefaultDegenWireframe {
    private weak var parent: UIViewController?
    private let currencySwapWireframeFactory: CurrencySwapWireframeFactory
    private let cultProposalsWireframeFactory: CultProposalsWireframeFactory
    private let alertWireframeFactory: AlertWireframeFactory
    private let degenService: DegenService
    private let networksService: NetworksService

    private weak var vc: UIViewController?

    init(
        _ parent: UIViewController,
        currencySwapWireframeFactory: CurrencySwapWireframeFactory,
        cultProposalsWireframeFactory: CultProposalsWireframeFactory,
        alertWireframeFactory: AlertWireframeFactory,
        degenService: DegenService,
        networksService: NetworksService
    ) {
        
        self.parent = parent
        self.currencySwapWireframeFactory = currencySwapWireframeFactory
        self.cultProposalsWireframeFactory = cultProposalsWireframeFactory
        self.alertWireframeFactory = alertWireframeFactory
        self.degenService = degenService
        self.networksService = networksService
    }
}

extension DefaultDegenWireframe {

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
        if destination is DegenWireframeDestination.Swap {
            guard let network = networksService.network else { return }
            let context = CurrencySwapWireframeContext(
                network: network, currencyFrom: nil, currencyTo: nil
            )
            currencySwapWireframeFactory.make(vc, context: context).present()
        }
        if destination is DegenWireframeDestination.Cult {
            cultProposalsWireframeFactory.make(vc).present()
        }
        if destination is DegenWireframeDestination.ComingSoon {
            alertWireframeFactory.make(vc, context: .underConstructionAlert()).present()
        }
    }
}

private extension DefaultDegenWireframe {

    func wireUp() -> UIViewController {
        let interactor = DefaultDegenInteractor(
            degenService: degenService,
            networksService: networksService
        )
        let vc: DegenViewController = UIStoryboard(.degen).instantiate()
        let presenter = DefaultDegenPresenter(
            view: WeakRef(referred: vc),
            wireframe: self,
            interactor: interactor
        )
        vc.presenter = presenter
        let nc = NavigationController(rootViewController: vc)
        nc.tabBarItem = UITabBarItem(
            title: Localized("degen"),
            image: UIImage(named: "tab_icon_degen"),
            tag: 1
        )
        self.vc = nc
        return nc
    }
}
