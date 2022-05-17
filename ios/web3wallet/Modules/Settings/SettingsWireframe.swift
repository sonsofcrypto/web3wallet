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

// MARK: - DefaultSettingsWireframe

final class DefaultSettingsWireframe {

    private weak var parent: UIViewController?
    private let context: SettingsWireframeContext
    private let settingsService: SettingsService
    private let keyStoreService: KeyStoreService
    
    private weak var vc: UIViewController?

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

// MARK: - SettingsWireframe

extension DefaultSettingsWireframe: SettingsWireframe {

    func present() {
        
        present(with: context)
    }

    func navigate(to destination: SettingsWireframeDestination) {
        
        switch destination {
            
        case let .settings(settings, title):
            
            present(
                with: .init(
                    title: title ?? Localized("settings"),
                    settings: settings
                )
            )
        }
    }
}

extension DefaultSettingsWireframe {
    
    func present(with context: SettingsWireframeContext) {
        
        let vc = wireUp(with: context)
        self.vc = vc

        if let tabVc = self.parent as? UITabBarController {
            let navVc = NavigationController(rootViewController:vc)
            let vcs = (tabVc.viewControllers ?? []) + [navVc]
            self.vc = navVc
            tabVc.setViewControllers(vcs, animated: false)
            return
        }

        parent?.show(vc, sender: self)
    }

    private func wireUp(with context: SettingsWireframeContext) -> UIViewController {
        
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
