//
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT
//

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
    private let degen: DegenWireframe
    private let nfts: NFTsWireframe
    private let apps: AppsWireframe
    private let settings: SettingsWireframe

    private weak var view: RootView?

    init(
        view: RootView,
        wireframe: RootWireframe,
        wallets: WalletsWireframe,
        networks: NetworksWireframe,
        dashboard: DashboardWireframe,
        degen: DegenWireframe,
        nfts: NFTsWireframe,
        apps: AppsWireframe,
        settings: SettingsWireframe
    ) {
        self.view = view
        self.wireframe = wireframe
        self.wallets = wallets
        self.networks = networks
        self.dashboard = dashboard
        self.degen = degen
        self.nfts = nfts
        self.apps = apps
        self.settings = settings
    }
}

// MARK: RootPresenter

extension DefaultRootPresenter: RootPresenter {

    func present() {
        dashboard.present()
        networks.present()
        wallets.present()
        degen.present()
        nfts.present()
        apps.present()
        settings.present()
    }
}
