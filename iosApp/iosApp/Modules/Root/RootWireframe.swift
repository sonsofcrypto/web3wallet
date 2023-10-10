// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

// MARK: - RootWireframeDestination

enum RootWireframeDestination {
    case dashboard
    case networks
    case keyStore
    case overview
    case overViewNetworks
    case overViewKeyStore
}

// MARK: - RootWireframe

protocol RootWireframe {
    func present()
    func navigate(to destination: RootWireframeDestination, animated: Bool)
}

// MARK: - DefaultRootWireframe

final class DefaultRootWireframe {
    private weak var window: UIWindow?
    private weak var vc: UIViewController!
    private weak var tabVc: TabBarController!

    private let keyStoreWireframeFactory: SignersWireframeFactory
    private let networksWireframeFactory: NetworksWireframeFactory
    private let dashboardWireframeFactory: DashboardWireframeFactory
    private let degenWireframeFactory: DegenWireframeFactory
    private let nftsDashboardWireframeFactory: NFTsDashboardWireframeFactory
    private let settingsWireframeFactory: SettingsWireframeFactory
    private let keyStoreService: KeyStoreService

    init(
        window: UIWindow?,
        keyStoreWireframeFactory: SignersWireframeFactory,
        networksWireframeFactory: NetworksWireframeFactory,
        dashboardWireframeFactory: DashboardWireframeFactory,
        degenWireframeFactory: DegenWireframeFactory,
        nftsDashboardWireframeFactory: NFTsDashboardWireframeFactory,
        settingsWireframeFactory: SettingsWireframeFactory,
        keyStoreService: KeyStoreService
    ) {
        self.window = window
        self.keyStoreWireframeFactory = keyStoreWireframeFactory
        self.networksWireframeFactory = networksWireframeFactory
        self.dashboardWireframeFactory = dashboardWireframeFactory
        self.degenWireframeFactory = degenWireframeFactory
        self.nftsDashboardWireframeFactory = nftsDashboardWireframeFactory
        self.settingsWireframeFactory = settingsWireframeFactory
        self.keyStoreService = keyStoreService
    }
}

extension DefaultRootWireframe: RootWireframe {

    func present() {
        let vc = wireUp()
        self.vc = vc
        keyStoreWireframeFactory.make(vc).present()
        networksWireframeFactory.makeWireframe(vc).present()
        dashboardWireframeFactory.make(tabVc).present()
        degenWireframeFactory.make(tabVc).present()
        nftsDashboardWireframeFactory.make(tabVc).present()
        settingsWireframeFactory.make(tabVc, screenId: .root).present()
        window?.rootViewController = vc
        window?.makeKeyAndVisible()
    }

    func navigate(to destination: RootWireframeDestination, animated: Bool) {
        guard let vc = self.vc as? EdgeCardsController else {
            print("Unable to navigate to \(destination)")
            return
        }
        vc.setDisplayMode(destination.toDisplayMode(), animated: animated)
    }
}

private extension DefaultRootWireframe {
    
    func wireUp() -> UIViewController {
        let vc: RootViewController = UIStoryboard(.main).instantiate()
        let tabVc = TabBarController()
        self.tabVc = tabVc
        vc.setMaster(vc: tabVc)
        let presenter = DefaultRootPresenter(
            view: vc,
            wireframe: self,
            keyStoreService: keyStoreService
        )
        vc.presenter = presenter
        return vc
    }
}

private extension RootWireframeDestination {

    func toDisplayMode() -> EdgeCardsController.DisplayMode {
        switch self {
        case .dashboard:
            return .master
        case .overview:
            return .overview
        case .networks:
            return .topCard
        case .keyStore:
            return .bottomCard
        case .overViewNetworks:
            return .overviewTopCard
        case .overViewKeyStore:
            return .overviewBottomCard
        }
    }
}
