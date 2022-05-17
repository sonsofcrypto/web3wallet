// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol RootWireframeFactory {

    func makeWireframe(in window: UIWindow?) -> RootWireframe
}

// MARK: - DefaultRootWireframeFactory

final class DefaultRootWireframeFactory {

    private let keyStoreWireframeFactory: KeyStoreWireframeFactory
    private let networksWireframeFactory: NetworksWireframeFactory
    private let dashboardWireframeFactory: DashboardWireframeFactory
    private let degenWireframeFactory: DegenWireframeFactory
    private let nftsWireframeFactory: NFTsWireframeFactory
    private let appsWireframeFactory: AppsWireframeFactory
    private let settingsWireframeFactory: SettingsWireframeFactory
    private let keyStoreService: KeyStoreService

    init(
        keyStoreWireframeFactory: KeyStoreWireframeFactory,
        networksWireframeFactory: NetworksWireframeFactory,
        dashboardWireframeFactory: DashboardWireframeFactory,
        degenWireframeFactory: DegenWireframeFactory,
        nftsWireframeFactory: NFTsWireframeFactory,
        appsWireframeFactory: AppsWireframeFactory,
        settingsWireframeFactory: SettingsWireframeFactory,
        keyStoreService: KeyStoreService
    ) {
        self.keyStoreWireframeFactory = keyStoreWireframeFactory
        self.networksWireframeFactory = networksWireframeFactory
        self.dashboardWireframeFactory = dashboardWireframeFactory
        self.degenWireframeFactory = degenWireframeFactory
        self.nftsWireframeFactory = nftsWireframeFactory
        self.appsWireframeFactory = appsWireframeFactory
        self.settingsWireframeFactory = settingsWireframeFactory
        self.keyStoreService = keyStoreService
    }
}

// MARK: - RootWireframeFactory

extension DefaultRootWireframeFactory: RootWireframeFactory {

    func makeWireframe(in window: UIWindow?) -> RootWireframe {
        
        DefaultRootWireframe(
            window: window,
            keyStoreWireframeFactory: keyStoreWireframeFactory,
            networksWireframeFactory: networksWireframeFactory,
            dashboardWireframeFactory: dashboardWireframeFactory,
            degenWireframeFactory: degenWireframeFactory,
            nftsWireframeFactory: nftsWireframeFactory,
            appsWireframeFactory: appsWireframeFactory,
            settingsWireframeFactory: settingsWireframeFactory,
            keyStoreService: keyStoreService
        )
    }
}
