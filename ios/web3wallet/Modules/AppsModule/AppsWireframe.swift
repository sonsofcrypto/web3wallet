// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

enum AppsWireframeDestination {

}

protocol AppsWireframe {
    func present()
    func navigate(to destination: AppsWireframeDestination)
}

// MARK: - DefaultAppsWireframe

class DefaultAppsWireframe {

    private let interactor: AppsInteractor

    private weak var window: UIWindow?

    init(
        interactor: AppsInteractor,
        window: UIWindow?
    ) {
        self.interactor = interactor
        self.window = window
    }
}

// MARK: - AppsWireframe

extension DefaultAppsWireframe: AppsWireframe {

    func present() {
        let vc = wireUp()
        window?.rootViewController = vc
        window?.makeKeyAndVisible()
    }

    func navigate(to destination: AppsWireframeDestination) {
        print("navigate to \(destination)")
    }
}

extension DefaultAppsWireframe {

    private func wireUp() -> UIViewController {
        let vc: AppsViewController = UIStoryboard(.main).instantiate()
        let presenter = DefaultAppsPresenter(
            view: vc,
            interactor: interactor,
            wireframe: self
        )

        vc.presenter = presenter
        return NavigationController(rootViewController: vc)
    }
}
