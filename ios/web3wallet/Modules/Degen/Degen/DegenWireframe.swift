// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

enum DegenWireframeDestination {
    case amms

}

protocol DegenWireframe {
    func present()
    func navigate(to destination: DegenWireframeDestination)
}

// MARK: - DefaultDegenWireframe

class DefaultDegenWireframe {

    private weak var parent: UIViewController?
    private weak var vc: UIViewController?

    private let interactor: DegenInteractor
    private let ammsWireframeFactory: AMMsWireframeFactory

    init(
        parent: UIViewController,
        interactor: DegenInteractor,
        ammsWireframeFactory: AMMsWireframeFactory
    ) {
        self.parent = parent
        self.interactor = interactor
        self.ammsWireframeFactory = ammsWireframeFactory
    }
}

// MARK: - DegenWireframe

extension DefaultDegenWireframe: DegenWireframe {

    func present() {
        let vc = wireUp()
        self.vc = vc

        if let tabVc = self.parent as? UITabBarController {
            let vcs = (tabVc.viewControllers ?? []) + [vc]
            tabVc.setViewControllers(vcs, animated: false)
            return
        }

        vc.show(vc, sender: self)
    }

    func navigate(to destination: DegenWireframeDestination) {
        guard let vc = self.vc else {
            print("DefaultDegenWireframe does not have a view")
            return
        }

        switch destination {
        case .amms:
            ammsWireframeFactory.makeWireframe(vc).present()
        }
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
