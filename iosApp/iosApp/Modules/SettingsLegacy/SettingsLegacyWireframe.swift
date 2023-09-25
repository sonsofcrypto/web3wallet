// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

final class DefaultSettingsLegacyWireframe {
    private weak var parent: UIViewController?
    private let context: SettingsLegacyWireframeContext
    private let settingsService: SettingsLegacyService
    private let settingsServiceActionTrigger: SettingsServiceActionTrigger
    
    private weak var vc: UIViewController?

    init(
        _ parent: UIViewController?,
        context: SettingsLegacyWireframeContext,
        settingsService: SettingsLegacyService,
        settingsServiceActionTrigger: SettingsServiceActionTrigger
    ) {
        self.parent = parent
        self.context = context
        self.settingsService = settingsService
        self.settingsServiceActionTrigger = settingsServiceActionTrigger
    }
}

extension DefaultSettingsLegacyWireframe {

    func present() {
        let vc = wireUp(with: context)
        self.vc = vc
        let nc = settingsNavigationController(with: vc)
        if let tabVc = parent as? UITabBarController {
            let vcs = (tabVc.viewControllers ?? []) + [nc]
            tabVc.setViewControllers(vcs, animated: false)
        } else {
            parent?.show(nc, sender: self)
        }
    }

    func navigate(to destination: SettingsLegacyWireframeDestination) {
        if let input = destination as? SettingsLegacyWireframeDestination.SettingsLegacy {
            pushSettingsVC(with: input.context)
        }
        if destination is SettingsLegacyWireframeDestination.Dismiss {
            vc?.popOrDismiss()
        }
    }
}

private extension DefaultSettingsLegacyWireframe {
    
    func pushSettingsVC(with context: SettingsLegacyWireframeContext) {
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
            tag: 3
        )
        return navigationController
    }

    func wireUp(with context: SettingsLegacyWireframeContext) -> UIViewController {
        let interactor = DefaultSettingsLegacyInteractor(
            settingsLegacyService: settingsService,
            settingsServiceActionTrigger: settingsServiceActionTrigger
        )
        let vc: SettingsLegacyViewController = UIStoryboard(.settingsLegacy).instantiate()
        let presenter = DefaultSettingsLegacyPresenter(
            view: WeakRef(referred: vc),
            wireframe: self,
            interactor: interactor,
            context: context
        )
        vc.presenter = presenter
        return vc
    }
}
