// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3lib

struct SettingsWireframeContext {
    
    let title: String
    let settings: [SettingsItem]
    
    static var `default`: Self {
        
        .init(
            title: Localized("settings"),
            settings: rootSettings
        )
    }
    
    private static var rootSettings: [SettingsItem] {
        
        [
            .group(
                title: Localized("settings.root.group.settings"),
                items: [
                    //.setting(setting: .onboardingMode),
                    //.setting(setting: .createWalletTransitionType),
                    .setting(setting: .theme)
                ]
            ),
            .group(
                title: Localized("settings.root.group.actions"),
                items: [
                    .action(type: .resetKeyStore)
                ]
            )
        ]
    }
}

enum SettingsWireframeDestination {
    
    case dismiss
    case settings(title: String, settings: [SettingsItem])
}

protocol SettingsWireframe {
    
    func present()
    func navigate(to destination: SettingsWireframeDestination)
}

final class DefaultSettingsWireframe {

    private weak var parent: UIViewController!
    private let context: SettingsWireframeContext
    private let settingsService: SettingsService
    private let keyStoreService: KeyStoreService
    
    private weak var navigationController: NavigationController!

    init(
        parent: UIViewController,
        context: SettingsWireframeContext,
        settingsService: SettingsService,
        keyStoreService: KeyStoreService
    ) {
        self.parent = parent
        self.context = context
        self.settingsService = settingsService
        self.keyStoreService = keyStoreService
    }
}

extension DefaultSettingsWireframe: SettingsWireframe {

    func present() {
        
        let viewController = wireUp(with: context)

        if let tabBarController = parent as? UITabBarController {
            
            let navController = makeNavigationController(with: viewController)
            let vcs = (tabBarController.viewControllers ?? []) + [navController]
            tabBarController.setViewControllers(vcs, animated: false)
        } else if let navigationController = parent.navigationController as? NavigationController {
            
            self.navigationController = navigationController
            navigationController.pushViewController(viewController, animated: true)
        } else if let navigationController = parent as? NavigationController {

            self.navigationController = navigationController
            navigationController.pushViewController(viewController, animated: true)
        }
    }

    func navigate(to destination: SettingsWireframeDestination) {
        
        switch destination {
            
        case .dismiss:
            
            navigationController.popViewController(animated: true)
            
        case let .settings(title, settings):
            
            pushSettingsVC(
                with: .init(
                    title: title,
                    settings: settings
                )
            )
        }
    }
}

private extension DefaultSettingsWireframe {
    
    func pushSettingsVC(with context: SettingsWireframeContext) {
        
        let viewController = wireUp(with: context)
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func makeNavigationController(
        with viewController: UIViewController
    ) -> NavigationController {
        
        let navigationController = NavigationController(
            rootViewController: viewController
        )
        
        navigationController.tabBarItem = UITabBarItem(
            title: Localized("settings"),
            image: UIImage(named: "tab_icon_settings"),
            tag: FeatureFlag.showAppsTab.isEnabled ? 4 : 3
        )
        
        self.navigationController = navigationController
        
        return navigationController
    }

    func wireUp(with context: SettingsWireframeContext) -> UIViewController {
        
        let interactor = DefaultSettingsInteractor(
            settingsService,
            keyStoreService: keyStoreService
        )
        let vc: SettingsViewController = UIStoryboard(.settings).instantiate()
        let presenter = DefaultSettingsPresenter(
            view: vc,
            interactor: interactor,
            wireframe: self,
            context: context
        )

        vc.presenter = presenter
        return vc
    }
}
