// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

enum NetworksWireframeDestinaiton {

}

protocol NetworksWireframe {
    func present()
    func navigate(to destination: NetworksWireframeDestinaiton)
}

// MARK: - DefaultNetworksWireframe

class DefaultNetworksWireframe {

    private let interactor: NetworksInteractor

    private weak var window: UIWindow?

    init(
        interactor: NetworksInteractor,
        window: UIWindow?
    ) {
        self.interactor = interactor
        self.window = window
    }
}

// MARK: - NetworksWireframe

extension DefaultNetworksWireframe: NetworksWireframe {

    func present() {
        let vc = wireUp()
        window?.rootViewController = vc
        window?.makeKeyAndVisible()
    }

    func navigate(to destination: NetworksWireframeDestinaiton) {
        print("navigate to \(destination)")
    }
}

extension DefaultNetworksWireframe {

    private func wireUp() -> UIViewController {
        let vc: NetworksViewController = UIStoryboard(.main).instantiate()
        let presenter = DefaultNetworksPresenter(
            view: vc,
            interactor: interactor,
            wireframe: self
        )

        vc.presenter = presenter
        return NavigationController(rootViewController: vc)
    }
}
