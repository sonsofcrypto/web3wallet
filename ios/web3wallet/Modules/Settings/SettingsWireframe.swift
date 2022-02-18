// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

enum SettingsWireframeDestination {

}

protocol SettingsWireframe {
    func present()
    func navigate(to destination: SettingsWireframeDestination)
}

// MARK: - DefaultSettingsWireframe

class DefaultSettingsWireframe {

    private let interactor: SettingsInteractor

    private weak var window: UIWindow?

    init(
        interactor: SettingsInteractor,
        window: UIWindow?
    ) {
        self.interactor = interactor
        self.window = window
    }
}

// MARK: - SettingsWireframe

extension DefaultSettingsWireframe: SettingsWireframe {

    func present() {
        let vc = wireUp()
        window?.rootViewController = vc
        window?.makeKeyAndVisible()
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
            interactor: interactor,
            wireframe: self
        )

        vc.presenter = presenter
        return NavigationController(rootViewController: vc)
    }
}
