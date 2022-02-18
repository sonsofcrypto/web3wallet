// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

enum DegenWireframeDestination {

}

protocol DegenWireframe {
    func present()
    func navigate(to destination: DashboardWireframeDestination)
}

// MARK: - DefaultDegenWireframe

class DefaultDegenWireframe {

    private let interactor: DegenInteractor

    private weak var window: UIWindow?

    init(
        interactor: DegenInteractor,
        window: UIWindow?
    ) {
        self.interactor = interactor
        self.window = window
    }
}

// MARK: - DegenWireframe

extension DefaultDegenWireframe: DashboardWireframe {

    func present() {
        let vc = wireUp()
        window?.rootViewController = vc
        window?.makeKeyAndVisible()
    }

    func navigate(to destination: DashboardWireframeDestination) {
        print("navigate to \(destination)")
    }
}

extension DefaultDegenWireframe {

    private func wireUp() -> UIViewController {
        let vc: DegenViewController = UIStoryboard(.main).instantiate()
        let presenter = DefaultDegenPresenter(
            view: vc,
            interactor: interactor,
            wireframe: self
        )

        vc.presenter = presenter
        return NavigationController(rootViewController: vc)
    }
}
