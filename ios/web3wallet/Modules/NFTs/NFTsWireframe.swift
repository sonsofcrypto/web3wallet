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

    private let interactor: NFTsInteractor

    private weak var window: UIWindow?

    init(
        interactor: NFTsInteractor,
        window: UIWindow?
    ) {
        self.interactor = interactor
        self.window = window
    }
}

// MARK: - NFTsWireframe

extension DefaultNFTsWireframe: NFTsWireframe {

    func present() {
        let vc = wireUp()
        window?.rootViewController = vc
        window?.makeKeyAndVisible()
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
