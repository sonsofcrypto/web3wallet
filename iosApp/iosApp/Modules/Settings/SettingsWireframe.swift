// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

struct SettingsWireframeContext {
    
    let title: String
    let groups: [Group]
    
    struct Group {
        
        let title: String?
        let items: [Setting]
    }
    
    static var `default`: SettingsWireframeContext {
        
        .init(
            title: Localized("settings.root.group.settings"),
            groups: [
                .init(
                    title: Localized("settings.root.group.settings"),
                    items: [
                        .init(
                            title: Localized("settings.debug"),
                            type: .item(.debug)
                        ),
                        .init(
                            title: Localized("settings.theme"),
                            type: .item(.theme)
                        )
                    ]
                ),
                .init(
                    title: Localized("settings.root.group.actions"),
                    items: [
                        .init(
                            title: Localized("settings.resetKeyStore"),
                            type: .action(
                                item: nil,
                                action: .resetKeystore,
                                showTickOnSelected: false
                            )
                        )
                    ]
                )
            ]
        )
    }
}

enum SettingsWireframeDestination {
    
    case dismiss
    case settings(context: SettingsWireframeContext)
}

protocol SettingsWireframe {
    
    func present()
    func navigate(to destination: SettingsWireframeDestination)
}

final class DefaultSettingsWireframe {

    private weak var parent: UIViewController!
    private let context: SettingsWireframeContext
    private let settingsService: SettingsService
    
    private weak var navigationController: NavigationController!

    init(
        parent: UIViewController,
        context: SettingsWireframeContext,
        settingsService: SettingsService
    ) {
        self.parent = parent
        self.context = context
        self.settingsService = settingsService
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
            
        case let .settings(context):
            
            pushSettingsVC(with: context)
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
            image: "tab_icon_settings".assetImage,
            tag: FeatureFlag.showAppsTab.isEnabled ? 4 : 3
        )
        
        self.navigationController = navigationController
        
        return navigationController
    }

    func wireUp(with context: SettingsWireframeContext) -> UIViewController {
        
        let interactor = DefaultSettingsInteractor(
            settingsService
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
