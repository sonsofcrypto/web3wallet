// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

protocol RootPresenter {

    func present()
}

// MARK: - DefaultRootPresenter

class DefaultRootPresenter {

    private let wireframe: RootWireframe
    private let wallets: WalletsWireframe
    private let networks: NetworksWireframe
    private let dashboard: DashboardWireframe

    private weak var view: RootView?

    init(
        view: RootView,
        wireframe: RootWireframe,
        wallets: WalletsWireframe,
        networks: NetworksWireframe,
        dashboard: DashboardWireframe
    ) {
        self.view = view
        self.wireframe = wireframe
        self.wallets = wallets
        self.networks = networks
        self.dashboard = dashboard
    }
}

// MARK: RootPresenter

extension DefaultRootPresenter: RootPresenter {

    func present() {
        dashboard.present()
        networks.present()
        wallets.present()
    }
}
