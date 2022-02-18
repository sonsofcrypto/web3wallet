// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

enum AccountWireframeDestination {

}

protocol AccountWireframe {
    func present()
    func navigate(to destination: AccountWireframeDestination)
}

// MARK: - DefaultAccountWireframe

class DefaultAccountWireframe {

    private let interactor: AccountInteractor

    private weak var window: UIWindow?

    init(
        interactor: AccountInteractor,
        window: UIWindow?
    ) {
        self.interactor = interactor
        self.window = window
    }
}

// MARK: - AccountWireframe

extension DefaultAccountWireframe: AccountWireframe {

    func present() {
        let vc = wireUp()
        window?.rootViewController = vc
        window?.makeKeyAndVisible()
    }

    func navigate(to destination: AccountWireframeDestination) {
        print("navigate to \(destination)")
    }
}

extension DefaultAccountWireframe {

    private func wireUp() -> UIViewController {
        let vc: AccountViewController = UIStoryboard(.main).instantiate()
        let presenter = DefaultAccountPresenter(
            view: vc,
            interactor: interactor,
            wireframe: self
        )

        vc.presenter = presenter
        return NavigationController(rootViewController: vc)
    }
}
