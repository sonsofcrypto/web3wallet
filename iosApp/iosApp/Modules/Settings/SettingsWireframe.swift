// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

struct SettingsWireframeContext {
    
    let title: String
    let settings: [SettingsItem]
}

enum SettingsWireframeDestination {
    case settings(settings: [SettingsItem], title: String?)
}

protocol SettingsWireframe {
    func present()
    func navigate(to destination: SettingsWireframeDestination)
}

final class DefaultSettingsWireframe {

    private weak var parent: UITabBarController!
    private let settingsService: SettingsService
    private let keyStoreService: OldKeyStoreService
    
    private weak var navigationController: NavigationController!

    init(
        parent: UITabBarController,
        settingsService: SettingsService,
        keyStoreService: OldKeyStoreService
    ) {
        self.parent = parent
        self.settingsService = settingsService
        self.keyStoreService = keyStoreService
    }
}

extension DefaultSettingsWireframe: SettingsWireframe {

    func present() {
        
        let viewController = wireUp(with: .init(title: "", settings: []))
        let navController = makeNavigationController(with: viewController)
        let vcs = (parent.viewControllers ?? []) + [navController]
        parent.setViewControllers(vcs, animated: false)
    }

    func navigate(to destination: SettingsWireframeDestination) {
        
        switch destination {
            
        case let .settings(settings, title):
            
            pushSettingsVC(
                with: .init(
                    title: title ?? Localized("settings"),
                    settings: settings
                )
            )
        }
    }
}

private extension DefaultSettingsWireframe {
    
    func pushSettingsVC(with context: SettingsWireframeContext) {
        
        let viewController = wireUp(with: context)
        navigationController.show(viewController, sender: self)
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
            tag: 4
        )
        
        self.navigationController = navigationController
        
        return navigationController
    }

    func wireUp(with context: SettingsWireframeContext) -> UIViewController {
        
        let interactor = DefaultSettingsInteractor(
            settingsService,
            keyStoreService: keyStoreService,
            title: context.title,
            settings: context.settings
        )
        let vc: SettingsViewController = UIStoryboard(.main).instantiate()
        let presenter = DefaultSettingsPresenter(
            view: vc,
            interactor: interactor,
            wireframe: self
        )

        vc.presenter = presenter
        return vc
    }
}
