//
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT
//

import UIKit

protocol RootWireframeFactory {

    func makeWireframe(
        with window: UIWindow?
    ) -> RootWireframe
}

final class DefaultRootWireframeFactory {

    private let wallets: WalletsWireframeFactory
    private let networks: NetworksWireframeFactory
    private let dashboard: DashboardWireframeFactory
    private let degen: DegenWireframeFactory
    private let nfts: NFTsWireframeFactory
    private let apps: AppsWireframeFactory
    private let settings: SettingsWireframeFactory

    init(
        wallets: WalletsWireframeFactory,
        networks: NetworksWireframeFactory,
        dashboard: DashboardWireframeFactory,
        degen: DegenWireframeFactory,
        nfts: NFTsWireframeFactory,
        apps: AppsWireframeFactory,
        settings: SettingsWireframeFactory
    ) {

        self.wallets = wallets
        self.networks = networks
        self.dashboard = dashboard
        self.degen = degen
        self.nfts = nfts
        self.apps = apps
        self.settings = settings
    }
}

extension DefaultRootWireframeFactory: RootWireframeFactory {

    func makeWireframe(
        with window: UIWindow?
    ) -> RootWireframe {
        
        DefaultRootWireframe(
            window: window,
            wallets: wallets,
            networks: networks,
            dashboard: dashboard,
            degen: degen,
            nfts: nfts,
            apps: apps,
            settings: settings
        )
    }
}
