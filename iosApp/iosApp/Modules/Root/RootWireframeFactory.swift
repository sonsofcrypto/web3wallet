// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3lib

// MARK: - RootWireframeFactory

protocol RootWireframeFactory {
    func make(_ window: UIWindow?) -> RootWireframe
}

// MARK: - DefaultRootWireframeFactory

final class DefaultRootWireframeFactory {
    private let keyStoreWireframeFactory: KeyStoreWireframeFactory
    private let networksWireframeFactory: NetworksWireframeFactory
    private let dashboardWireframeFactory: DashboardWireframeFactory
    private let degenWireframeFactory: DegenWireframeFactory
    private let nftsDashboardWireframeFactory: NFTsDashboardWireframeFactory
    private let appsWireframeFactory: AppsWireframeFactory
    private let settingsWireframeFactory: SettingsWireframeFactory
    private let keyStoreService: KeyStoreService

    init(
        keyStoreWireframeFactory: KeyStoreWireframeFactory,
        networksWireframeFactory: NetworksWireframeFactory,
        dashboardWireframeFactory: DashboardWireframeFactory,
        degenWireframeFactory: DegenWireframeFactory,
        nftsDashboardWireframeFactory: NFTsDashboardWireframeFactory,
        appsWireframeFactory: AppsWireframeFactory,
        settingsWireframeFactory: SettingsWireframeFactory,
        keyStoreService: KeyStoreService
    ) {
        self.keyStoreWireframeFactory = keyStoreWireframeFactory
        self.networksWireframeFactory = networksWireframeFactory
        self.dashboardWireframeFactory = dashboardWireframeFactory
        self.degenWireframeFactory = degenWireframeFactory
        self.nftsDashboardWireframeFactory = nftsDashboardWireframeFactory
        self.appsWireframeFactory = appsWireframeFactory
        self.settingsWireframeFactory = settingsWireframeFactory
        self.keyStoreService = keyStoreService
    }
}

// MARK: - RootWireframeFactory

extension DefaultRootWireframeFactory: RootWireframeFactory {

    func make(_ window: UIWindow?) -> RootWireframe {
        DefaultRootWireframe(
            window: window,
            keyStoreWireframeFactory: keyStoreWireframeFactory,
            networksWireframeFactory: networksWireframeFactory,
            dashboardWireframeFactory: dashboardWireframeFactory,
            degenWireframeFactory: degenWireframeFactory,
            nftsDashboardWireframeFactory: nftsDashboardWireframeFactory,
            appsWireframeFactory: appsWireframeFactory,
            settingsWireframeFactory: settingsWireframeFactory,
            keyStoreService: keyStoreService
        )
    }
}

// MARK: - Assembler

final class RootWireframeFactoryAssembler: AssemblerComponent {

    func register(to registry: AssemblerRegistry) {
        registry.register(scope: .instance) { resolver -> RootWireframeFactory in
            DefaultRootWireframeFactory(
                keyStoreWireframeFactory: resolver.resolve(),
                networksWireframeFactory: resolver.resolve(),
                dashboardWireframeFactory: resolver.resolve(),
                degenWireframeFactory: resolver.resolve(),
                nftsDashboardWireframeFactory: resolver.resolve(),
                appsWireframeFactory: resolver.resolve(),
                settingsWireframeFactory: resolver.resolve(),
                keyStoreService: resolver.resolve()
            )
        }
    }
}
