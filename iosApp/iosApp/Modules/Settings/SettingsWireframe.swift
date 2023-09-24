// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

final class DefaultSettingsWireframe {
    private weak var parent: UIViewController?
    private let context: SettingsWireframeContext
    private let settingsService: SettingsService
    private let settingsServiceActionTrigger: SettingsServiceActionTrigger
    
    private weak var vc: UIViewController?

    init(
        _ parent: UIViewController?,
        context: SettingsWireframeContext,
        settingsService: SettingsService,
        settingsServiceActionTrigger: SettingsServiceActionTrigger
    ) {
        self.parent = parent
        self.context = context
        self.settingsService = settingsService
        self.settingsServiceActionTrigger = settingsServiceActionTrigger
    }
}

extension DefaultSettingsWireframe {

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

    func navigate(to destination: SettingsWireframeDestination) {
        if let input = destination as? SettingsWireframeDestination.Settings {
            pushSettingsVC(with: input.context)
        }
        if destination is SettingsWireframeDestination.Dismiss {
            vc?.popOrDismiss()
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
            tag: 3
        )
        return navigationController
    }

    func wireUp(with context: SettingsWireframeContext) -> UIViewController {
        let interactor = DefaultSettingsInteractor(
            settingsService: settingsService,
            settingsServiceActionTrigger: settingsServiceActionTrigger
        )
        let vc: SettingsViewController = UIStoryboard(.settings).instantiate()
        let presenter = DefaultSettingsPresenter(
            view: WeakRef(referred: vc),
            wireframe: self,
            interactor: interactor,
            context: context
        )
        vc.presenter = presenter
        return vc
    }
}
