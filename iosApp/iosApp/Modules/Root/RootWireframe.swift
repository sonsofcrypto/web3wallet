// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3lib

enum RootWireframeDestination {
    case dashboard
    case networks
    case keyStore
    case overview
    case overViewNetworks
    case overViewKeyStore
}

protocol RootWireframe {
    func present()
    func navigate(to destination: RootWireframeDestination, animated: Bool)
}

// MARK: - DefaultRootWireframe

final class DefaultRootWireframe {

    private weak var window: UIWindow?
    private weak var vc: UIViewController!
    private weak var tabVc: TabBarController!

    private let keyStoreWireframeFactory: KeyStoreWireframeFactory
    private let networksWireframeFactory: NetworksWireframeFactory
    private let dashboardWireframeFactory: DashboardWireframeFactory
    private let degenWireframeFactory: DegenWireframeFactory
    private let nftsDashboardWireframeFactory: NFTsDashboardWireframeFactory
    private let appsWireframeFactory: AppsWireframeFactory
    private let settingsWireframeFactory: SettingsWireframeFactory
    private let keyStoreService: KeyStoreService

    init(
        window: UIWindow?,
        keyStoreWireframeFactory: KeyStoreWireframeFactory,
        networksWireframeFactory: NetworksWireframeFactory,
        dashboardWireframeFactory: DashboardWireframeFactory,
        degenWireframeFactory: DegenWireframeFactory,
        nftsDashboardWireframeFactory: NFTsDashboardWireframeFactory,
        appsWireframeFactory: AppsWireframeFactory,
        settingsWireframeFactory: SettingsWireframeFactory,
        keyStoreService: KeyStoreService
    ) {
        
        self.window = window
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

// MARK: - RootWireframe

extension DefaultRootWireframe: RootWireframe {

    func present() {
        
        let vc = wireUp()
        self.vc = vc
        
        keyStoreWireframeFactory.makeWireframe(vc, window: nil).present()
        networksWireframeFactory.makeWireframe(vc).present()
        dashboardWireframeFactory.makeWireframe(tabVc).present()
        degenWireframeFactory.makeWireframe(tabVc).present()
        nftsDashboardWireframeFactory.makeWireframe(tabVc).present()
        if FeatureFlag.embedChatInTab.isEnabled {
            
            let chatWireframeFactory: ChatWireframeFactory = ServiceDirectory.assembler.resolve()
            chatWireframeFactory.makeWireframe(
                presentingIn: tabVc,
                context: .init(presentationStyle: .embed)
            ).present()
        } else {
            appsWireframeFactory.makeWireframe(tabVc).present()
        }
        settingsWireframeFactory.makeWireframe(tabVc).present()
        
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

extension DefaultRootWireframe {

    private func wireUp() -> UIViewController {
        
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
        case .keyStore:
            return .bottomCard
        case .overViewNetworks:
            return .overviewTopCard
        case .overViewKeyStore:
            return .overviewBottomCard
        }
    }
}
