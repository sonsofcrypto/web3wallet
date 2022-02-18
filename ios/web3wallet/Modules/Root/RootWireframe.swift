// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

enum RootWireframeDestination {
    case dashboard
    case overview
    case networks
    case wallets
}

protocol RootWireframe {
    func present()
    func navigate(to destination: RootWireframeDestination)
}

// MARK: - DefaultRootWireframe

class DefaultRootWireframe {

    private weak var window: UIWindow?
    private weak var vc: UIViewController?

    private let wallets: WalletsWireframeFactory
    private let networks: NetworksWireframeFactory
    private let dashboard: DashboardWireframeFactory

    init(
        window: UIWindow?,
        wallets: WalletsWireframeFactory,
        networks: NetworksWireframeFactory,
        dashboard: DashboardWireframeFactory
    ) {
        self.window = window
        self.wallets = wallets
        self.networks = networks
        self.dashboard = dashboard
    }
}

// MARK: - RootWireframe

extension DefaultRootWireframe: RootWireframe {

    func present() {
        let vc = wireUp()
        self.vc = vc
        window?.rootViewController = vc
        window?.makeKeyAndVisible()
    }

    func navigate(to destination: RootWireframeDestination) {
        guard let vc = self.vc as? EdgeCardsController else {
            print("Unable to navigate to \(destination)")
            return
        }
        vc.setDisplayMode(destination.toDisplayMode(), animated: true)
    }
}

extension DefaultRootWireframe {

    private func wireUp() -> UIViewController {
        let vc: RootViewController = UIStoryboard(.main).instantiate()
        let presenter = DefaultRootPresenter(
            view: vc,
            wireframe: self
        )

        vc.presenter = presenter
        return vc
    }
}

// MARK: - RootWireframeDestination to EdgeCardsController.DisplayMode

private extension RootWireframeDestination {

    func toDisplayMode() -> EdgeCardsController.DisplayMode {
        switch self {
        case .dashboard:
            return .master
        case .overview:
            return .overview
        case .networks:
            return .topCard
        case .wallets:
            return .bottomCard
        }
    }
}
