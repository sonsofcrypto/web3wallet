// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

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

    func navigate(destination___________ destination: NetworksWireframeDestination) {
        if destination is NetworksWireframeDestination.Dashboard {
            parent?.asEdgeCardsController?.setDisplayMode(.master, animated: true)
        }
        if let input = destination as? NetworksWireframeDestination.EditNetwork {
            alertWireframeFactory.make(
                parent,
                context: .underConstructionAlert()
             )
 //             networkSettingsWireframeFactory.make(
 //                 vc?.asNavVc?.topVc ?? vc,
 //                 network: input.network
 //             ).present()
        }
    }
}

private extension DefaultNetworksWireframe {

    func wireUp() -> UIViewController {
        let interactor = DefaultNetworksInteractor(networksService: networksService)
        let vc: NetworksViewController = UIStoryboard(.networks).instantiate()
        let presenter = DefaultNetworksPresenter(
            view: WeakRef(referred: vc),
            wireframe: self,
            interactor: interactor
        )
        vc.presenter = presenter
        return NavigationController(rootViewController: vc)
    }
}
