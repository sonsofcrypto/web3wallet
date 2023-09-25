// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

enum SettingsWireframeDestination {

}

struct SettingsWireframeContext {
    
}

protocol SettingsWireframe {
    func present()
    func navigate(to destination: SettingsWireframeDestination)
}

// MARK: - DefaultSettingsWireframe

class DefaultSettingsWireframe {
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

// MARK: - TemplateWireframe

extension DefaultSettingsWireframe: SettingsWireframe {

    func present() {
        let vc = wireUp()
        self.vc = vc

        if let tabVc = parent as? UITabBarController {
            let vcs = (tabVc.viewControllers ?? []) + [vc]
            tabVc.setViewControllers(vcs, animated: false)
        } else {
            parent?.show(vc, sender: self)
        }
    }

    func navigate(to destination: SettingsWireframeDestination) {
        print("navigate to \(destination)")
    }
}

extension DefaultSettingsWireframe {

    private func wireUp() -> UIViewController {
        let vc: SettingsViewController = UIStoryboard(.main).instantiate()
        let presenter = DefaultSettingsPresenter(
            view: vc,
            interactor: DefaultSettingsInteractor(settingsService),
            wireframe: self
        )
        vc.presenter = presenter

        let nc = NavigationController(rootViewController: vc)

        nc.tabBarItem = UITabBarItem(
            title: Localized("settings"),
            image: "tab_icon_settings".assetImage,
            tag: 4
        )

        return nc
    }
}
