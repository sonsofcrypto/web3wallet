// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

enum WalletsWireframeDestinaiton {
    case walletSettings
    case networks
    case homeScreen
}

protocol WalletsWireframe {
    func present()
    func navigate(to destination: WalletsWireframeDestinaiton)
}

// MARK: - DefaultWalletsWireframe

class DefaultWalletsWireframe {

    private let interactor: WalletsInteractor

    private weak var window: UIWindow?

    init(
        interactor: WalletsInteractor,
        window: UIWindow?
    ) {
        self.interactor = interactor
        self.window = window
    }
}

// MARK: - WalletsWireframe

extension DefaultWalletsWireframe: WalletsWireframe {

    func present() {
        let vc = wireUp()
        window?.rootViewController = vc
        window?.makeKeyAndVisible()
    }

    func navigate(to destination: WalletsWireframeDestinaiton) {
        print("navigate to \(destination)")
    }
}

extension DefaultWalletsWireframe {

    private func wireUp() -> UIViewController {
        let vc: WalletsViewController = UIStoryboard(.main).instantiate()
        let presenter = DefaultWalletsPresenter(
            view: vc,
            interactor: interactor,
            wireframe: self
        )

        vc.presenter = presenter
        return UINavigationController(rootViewController: vc)
    }
}
