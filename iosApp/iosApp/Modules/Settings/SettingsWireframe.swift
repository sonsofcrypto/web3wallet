// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

class DefaultSettingsWireframe {
    private weak var parent: UIViewController?
    private let destination: SettingsWireframeDestination
    private let settingsService: SettingsService
    
    private weak var vc: UIViewController?

    init(
        _ parent: UIViewController?,
        destination: SettingsWireframeDestination,
        settingsService: SettingsService
    ) {
        self.parent = parent
        self.destination = destination
        self.settingsService = settingsService
    }
}

// MARK: - TemplateWireframe

extension DefaultSettingsWireframe {

    func present() {
        let vc = wireUp()
        self.vc = vc

        if let tabVc = parent as? UITabBarController {
            let nc = NavigationController(rootViewController: vc)
            nc.tabBarItem = UITabBarItem(
                title: Localized("settings"),
                image: "tab_icon_settings".assetImage,
                tag: 4
            )
            let vcs = (tabVc.viewControllers ?? []) + [nc]
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
            view: WeakRef(referred: vc),
            wireframe: self,
            interactor: DefaultSettingsInteractor(
                settingsService: settingsService
            ),
            destination: destination
        )
        vc.presenter = presenter
        return vc
    }
}
