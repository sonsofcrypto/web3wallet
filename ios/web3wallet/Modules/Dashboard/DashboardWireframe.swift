// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

enum DashboardWireframeDestinaiton {

}

protocol DashboardWireframe {
    func present()
    func navigate(to destination: DashboardWireframeDestinaiton)
}

// MARK: - DefaultDashboardWireframe

class DefaultDashboardWireframe {

    private let interactor: DashboardInteractor

    private weak var window: UIWindow?

    init(
        interactor: DashboardInteractor,
        window: UIWindow?
    ) {
        self.interactor = interactor
        self.window = window
    }
}

// MARK: - DashboardWireframe

extension DefaultDashboardWireframe: DashboardWireframe {

    func present() {
        let vc = wireUp()
        window?.rootViewController = vc
        window?.makeKeyAndVisible()
    }

    func navigate(to destination: DashboardWireframeDestinaiton) {
        print("navigate to \(destination)")
    }
}

extension DefaultDashboardWireframe {

    private func wireUp() -> UIViewController {
        let vc: WalletsViewController = UIStoryboard(.main).instantiate()
        let presenter = DefaultTemplatePresenter(
            view: vc,
            interactor: interactor,
            wireframe: self
        )

        vc.presenter = presenter
        return NavigationController(rootViewController: vc)
    }
}
