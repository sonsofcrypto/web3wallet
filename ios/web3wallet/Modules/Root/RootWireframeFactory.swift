// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol RootWireframeFactory {

    func makeWireframe() -> RootWireframe
}

// MARK: - DefaultRootWireframeFactory

class DefaultRootWireframeFactory {

    private weak var window: UIWindow?

    private let wallets: WalletsWireframeFactory
    private let networks: NetworksWireframeFactory
    private let dashboard: DashboardWireframeFactory
    private let degen: DegenWireframeFactory

    init(
        window: UIWindow?,
        wallets: WalletsWireframeFactory,
        networks: NetworksWireframeFactory,
        dashboard: DashboardWireframeFactory,
        degen: DegenWireframeFactory
    ) {
        self.window = window
        self.wallets = wallets
        self.networks = networks
        self.dashboard = dashboard
        self.degen = degen
    }
}

// MARK: - RootWireframeFactory

extension DefaultRootWireframeFactory: RootWireframeFactory {

    func makeWireframe() -> RootWireframe {
        DefaultRootWireframe(
            window: window,
            wallets: wallets,
            networks: networks,
            dashboard: dashboard,
            degen: degen
        )
    }
}