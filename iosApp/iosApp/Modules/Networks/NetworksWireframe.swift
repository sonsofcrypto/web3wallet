// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3lib

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
    private let networksService: NetworksService

    init(
        parent: UIViewController?,
        networksService: NetworksService,
        alertWireframeFactory: AlertWireframeFactory
    ) {
        self.parent = parent
        self.networksService = networksService
        self.alertWireframeFactory = alertWireframeFactory
    }
}

extension DefaultNetworksWireframe: NetworksWireframe {

    func present() {
        let vc = wireUp()
        if let parent = self.parent as? EdgeCardsController {
            parent.setTopCard(vc: vc)
        } else {
            parent?.show(vc, sender: self)
        }
    }

    func navigate(to destination: NetworksWireframeDestination) {
        switch destination {
        case .dashboard:
            guard let parent = parent as? EdgeCardsController else {
                return
            }
            parent.setDisplayMode(.master, animated: true)
        case .editNetwork:
            guard let parent = parent else { return }
            alertWireframeFactory.makeWireframe(
                parent,
                context: .underConstructionAlert()
            ).present()
        }
    }
}

extension DefaultNetworksWireframe {

    private func wireUp() -> UIViewController {
        let interactor = DefaultNetworksInteractor(networksService)
        let vc: NetworksViewController = UIStoryboard(.networks).instantiate()
        let presenter = DefaultNetworksPresenter(
            view: vc,
            interactor: interactor,
            wireframe: self
        )
        vc.presenter = presenter
        return NavigationController(rootViewController: vc)
    }
}
