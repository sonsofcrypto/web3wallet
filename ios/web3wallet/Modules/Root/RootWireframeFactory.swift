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

    private let onboardingService: OnboardingService
    private let keyStoreService: KeyStoreService
    private let settingsService: SettingsService
    private let keyStore: KeyStoreWireframeFactory
    private let networks: NetworksWireframeFactory
    private let dashboard: DashboardWireframeFactory
    private let degen: DegenWireframeFactory
    private let nfts: NFTsWireframeFactory
    private let apps: AppsWireframeFactory
    private let settings: SettingsWireframeFactory

    init(
        window: UIWindow?,
        onboardingService: OnboardingService,
        keyStoreService: KeyStoreService,
        settingsService: SettingsService,
        keyStore: KeyStoreWireframeFactory,
        networks: NetworksWireframeFactory,
        dashboard: DashboardWireframeFactory,
        degen: DegenWireframeFactory,
        nfts: NFTsWireframeFactory,
        apps: AppsWireframeFactory,
        settings: SettingsWireframeFactory
    ) {
        self.window = window
        self.onboardingService = onboardingService
        self.keyStoreService = keyStoreService
        self.settingsService = settingsService
        self.keyStore = keyStore
        self.networks = networks
        self.dashboard = dashboard
        self.degen = degen
        self.nfts = nfts
        self.apps = apps
        self.settings = settings
    }
}

// MARK: - RootWireframeFactory

extension DefaultRootWireframeFactory: RootWireframeFactory {

    func makeWireframe() -> RootWireframe {
        DefaultRootWireframe(
            window: window,
            onboardingService: onboardingService,
            keyStoreService: keyStoreService,
            settingsService: settingsService,
            keyStore: keyStore,
            networks: networks,
            dashboard: dashboard,
            degen: degen,
            nfts: nfts,
            apps: apps,
            settings: settings
        )
    }
}