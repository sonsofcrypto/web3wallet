// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

enum NFTsWireframeDestination {

}

protocol NFTsWireframe {
    func present()
    func navigate(to destination: NFTsWireframeDestination)
}

// MARK: - DefaultNFTsWireframe

class DefaultNFTsWireframe {

    private weak var parent: UIViewController?

    private let interactor: NFTsInteractor

    private weak var window: UIWindow?

    init(
        parent: UIViewController,
        interactor: NFTsInteractor
    ) {
        self.parent = parent
        self.interactor = interactor
    }
}

// MARK: - NFTsWireframe

extension DefaultNFTsWireframe: NFTsWireframe {

    func present() {
        let vc = wireUp()

        if let tabVc = self.parent as? UITabBarController {
            let vcs = (tabVc.viewControllers ?? []) + [vc]
            tabVc.setViewControllers(vcs, animated: false)
            return
        }

        vc.show(vc, sender: self)
    }

    func navigate(to destination: NFTsWireframeDestination) {
        print("navigate to \(destination)")
    }
}

extension DefaultNFTsWireframe {

    private func wireUp() -> UIViewController {
        let vc: NFTsViewController = UIStoryboard(.main).instantiate()
        let presenter = DefaultNFTsPresenter(
            view: vc,
            interactor: interactor,
            wireframe: self
        )

        vc.presenter = presenter
        return NavigationController(rootViewController: vc)
    }
}
