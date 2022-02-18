// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

enum RootWireframeDestination {

}

protocol RootWireframe {
    func present()
    func navigate(to destination: RootWireframeDestination)
}

// MARK: - DefaultRootWireframe

class DefaultRootWireframe {

    private weak var window: UIWindow?

    init(
        window: UIWindow?
    ) {
        self.window = window
    }
}

// MARK: - RootWireframe

extension DefaultRootWireframe: RootWireframe {

    func present() {
        let vc = wireUp()
        window?.rootViewController = vc
        window?.makeKeyAndVisible()
    }

    func navigate(to destination: RootWireframeDestination) {
        print("navigate to \(destination)")
    }
}

extension DefaultRootWireframe {

    private func wireUp() -> UIViewController {
        let vc: RootViewController = UIStoryboard(.main).instantiate()
        let presenter = DefaultRootPresenter(
            view: vc,
            wireframe: self
        )

        vc.presenter = presenter
        return NavigationController(rootViewController: vc)
    }
}
