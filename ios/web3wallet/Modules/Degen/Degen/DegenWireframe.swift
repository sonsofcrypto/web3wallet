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

    private weak var parent: UIViewController?

    private let interactor: DegenInteractor

    init(
        parent: UIViewController,
        interactor: DegenInteractor
    ) {
        self.parent = parent
        self.interactor = interactor
    }
}

// MARK: - DegenWireframe

extension DefaultDegenWireframe: DegenWireframe {

    func present() {
        let vc = wireUp()
        if let tabVc = self.parent as? UITabBarController {
            tabVc.setViewControllers(
                (tabVc.viewControllers ?? []) + [vc],
                animated: true
            )
            return
        }
        vc.show(vc, sender: self)
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
