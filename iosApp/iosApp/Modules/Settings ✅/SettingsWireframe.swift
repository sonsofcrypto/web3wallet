// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

// MARK: - SettingsWireframeDestination

enum SettingsWireframeDestination {
    case dismiss
    case settings(context: SettingsWireframeContext)
}

// MARK: - SettingsWireframe

protocol SettingsWireframe {
    func present()
    func navigate(to destination: SettingsWireframeDestination)
}

// MARK: - DefaultSettingsWireframe

final class DefaultSettingsWireframe {
    private weak var parent: UIViewController?
    private let context: SettingsWireframeContext
    private let settingsService: SettingsService
    
    private weak var vc: UIViewController?

    init(
        _ parent: UIViewController?,
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
        let vc = wireUp(with: context)
        guard let tabBarController = parent as? UITabBarController else {
            parent?.show(vc, sender: self)
            return
        }
        let navController = settingsNavigationController(with: vc)
        let vcs = (tabBarController.viewControllers ?? []) + [navController]
        tabBarController.setViewControllers(vcs, animated: false)
    }

    func navigate(to destination: SettingsWireframeDestination) {
        switch destination {
        case .dismiss:
            if let nc = vc as? NavigationController {
                nc.popViewController(animated: true)
            } else {
                vc?.dismiss(animated: true)
            }
        case let .settings(context):
            pushSettingsVC(with: context)
        }
    }
}

private extension DefaultSettingsWireframe {
    
    func pushSettingsVC(with context: SettingsWireframeContext) {
        let vc = wireUp(with: context)
        self.vc?.show(vc, sender: self)
    }
    
    func settingsNavigationController(
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
        self.vc = navigationController
        return navigationController
    }

    func wireUp(with context: SettingsWireframeContext) -> UIViewController {
        let interactor = DefaultSettingsInteractor(
            settingsService
        )
        let vc: SettingsViewController = UIStoryboard(.settings).instantiate()
        let presenter = DefaultSettingsPresenter(
            view: vc,
            wireframe: self,
            interactor: interactor,
            context: context
        )
        vc.presenter = presenter
        return vc
    }
}
