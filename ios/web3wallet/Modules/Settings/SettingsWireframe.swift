// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

enum SettingsWireframeDestination {
    case settings(settings: [SettingsItem], title: String?)
}

protocol SettingsWireframe {
    func present()
    func navigate(to destination: SettingsWireframeDestination)
}

// MARK: - DefaultSettingsWireframe

class DefaultSettingsWireframe {

    private weak var parent: UIViewController?
    private weak var vc: UIViewController?

    private let interactor: SettingsInteractor
    private let settingsWireframeFactory: SettingsWireframeFactory

    init(
        parent: UIViewController,
        interactor: SettingsInteractor,
        settingsWireframeFactory: SettingsWireframeFactory
    ) {
        self.parent = parent
        self.interactor = interactor
        self.settingsWireframeFactory = settingsWireframeFactory
    }
}

// MARK: - SettingsWireframe

extension DefaultSettingsWireframe: SettingsWireframe {

    func present() {
        let vc = wireUp()
        self.vc = vc

        if let tabVc = self.parent as? UITabBarController {
            let navVc = NavigationController(rootViewController:vc)
            let vcs = (tabVc.viewControllers ?? []) + [navVc]
            self.vc = navVc
            tabVc.setViewControllers(vcs, animated: false)
            return
        }
        print("showing", parent)
        parent?.show(vc, sender: self)
    }

    func navigate(to destination: SettingsWireframeDestination) {
        switch destination {
        case let .settings(settings, title):
            guard let vc = self.vc else {
                return
            }
            print(vc)
            print((vc as? UINavigationController)?.topViewController ?? vc)
            settingsWireframeFactory.makeWireframe(
                (vc as? UINavigationController)?.topViewController ?? vc,
                title: title ?? Localized("settings"),
                settings: settings,
                settingsWireframeFactory: settingsWireframeFactory
            ).present()
        }
    }
}

extension DefaultSettingsWireframe {

    private func wireUp() -> UIViewController {
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
