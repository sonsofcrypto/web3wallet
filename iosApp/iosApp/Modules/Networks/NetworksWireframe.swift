// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

enum NetworksWireframeDestination {
    case dashboard
    case editNetwork(Network)
}

protocol NetworksWireframe {
    func present()
    func navigate(to destination: NetworksWireframeDestination)
}

final class DefaultNetworksWireframe {
    private weak var parent: UIViewController?
    private let alertWireframeFactory: AlertWireframeFactory
    private let networkSettingsWireframeFactory: NetworkSettingsWireframeFactory
    private let networksService: NetworksService

    private weak var vc: UIViewController?

    init(
        parent: UIViewController?,
        networksService: NetworksService,
        alertWireframeFactory: AlertWireframeFactory,
        networkSettingsWireframeFactory: NetworkSettingsWireframeFactory
    ) {
        self.parent = parent
        self.networksService = networksService
        self.alertWireframeFactory = alertWireframeFactory
        self.networkSettingsWireframeFactory = networkSettingsWireframeFactory
    }
}

extension DefaultNetworksWireframe: NetworksWireframe {

    func present() {
        let vc = wireUp()
        self.vc = vc
        parent?.asEdgeCardsController?.setTopCard(vc: vc) ?? parent?.show(vc, sender: self)
        if let parent = self.parent as? EdgeCardsController {
            parent.setTopCard(vc: vc)
        } else {
            parent?.show(vc, sender: self)
        }
    }

    func navigate(to destination: NetworksWireframeDestination) {
        switch destination {
        case .dashboard:
            parent?.asEdgeCardsController?.setDisplayMode(.master, animated: true)
        case let .editNetwork(network):
           alertWireframeFactory.make(
               parent,
               context: .underConstructionAlert()
            )
//             networkSettingsWireframeFactory.make(
//                 vc?.asNavVc?.topVc ?? vc,
//                 network: network
//             ).present()
        }
    }
}

private extension DefaultNetworksWireframe {

    func wireUp() -> UIViewController {
        let interactor = DefaultNetworksInteractor(networksService)
        let vc: NetworksViewController = UIStoryboard(.networks).instantiate()
        let presenter = DefaultNetworksPresenter(
            view: vc,
            wireframe: self,
            interactor: interactor
        )
        vc.presenter = presenter
        return NavigationController(rootViewController: vc)
    }
}
