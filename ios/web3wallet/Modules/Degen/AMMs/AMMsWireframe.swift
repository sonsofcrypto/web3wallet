// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

enum AMMsWireframeDestination {

}

protocol AMMsWireframe {
    func present()
    func navigate(to destination: AMMsWireframeDestination)
}

// MARK: - DefaultAMMsWireframe

class DefaultAMMsWireframe {

    private let interactor: AMMsInteractor

    private weak var window: UIWindow?

    init(
        interactor: AMMsInteractor,
        window: UIWindow?
    ) {
        self.interactor = interactor
        self.window = window
    }
}

// MARK: - AMMsWireframe

extension DefaultAMMsWireframe: AMMsWireframe {

    func present() {
        let vc = wireUp()
        window?.rootViewController = vc
        window?.makeKeyAndVisible()
    }

    func navigate(to destination: AMMsWireframeDestinaiton) {
        print("navigate to \(destination)")
    }
}

extension DefaultAMMsWireframe {

    private func wireUp() -> UIViewController {
        let vc: AMMsViewController = UIStoryboard(.main).instantiate()
        let presenter = DefaultAMMsPresenter(
            view: vc,
            interactor: interactor,
            wireframe: self
        )

        vc.presenter = presenter
        return NavigationController(rootViewController: vc)
    }
}
