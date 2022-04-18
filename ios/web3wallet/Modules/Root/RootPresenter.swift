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
    private let onboardingService: OnboardingService
    private let keyStoreService: KeyStoreService
    private let keyStore: KeyStoreWireframe
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
        onboardingService: OnboardingService,
        keyStoreService: KeyStoreService,
        keyStore: KeyStoreWireframe,
        networks: NetworksWireframe,
        dashboard: DashboardWireframe,
        degen: DegenWireframe,
        nfts: NFTsWireframe,
        apps: AppsWireframe,
        settings: SettingsWireframe
    ) {
        self.view = view
        self.wireframe = wireframe
        self.onboardingService = onboardingService
        self.keyStoreService = keyStoreService
        self.keyStore = keyStore
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
        if onboardingService.shouldCreateWalletAtFirstLaunch()
           && keyStoreService.isEmpty() {
            keyStoreService.createDefaultKeyStoreItem()
        }
        dashboard.present()
        networks.present()
        keyStore.present()
        degen.present()
        nfts.present()
        apps.present()
        settings.present()
        wireframe.navigate(
            to: keyStoreService.isEmpty() ? .keyStore : .dashboard,
            animated: false
        )
    }
}
