// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

enum SwapWireframeDestination {

}

protocol SwapWireframe {
    func present()
    func navigate(to destination: SwapWireframeDestination)
}

// MARK: - DefaultSwapWireframe

class DefaultSwapWireframe {

    private let interactor: SwapInteractor

    private weak var window: UIWindow?

    init(
        interactor: SwapInteractor,
        window: UIWindow?
    ) {
        self.interactor = interactor
        self.window = window
    }
}

// MARK: - SwapWireframe

extension DefaultSwapWireframe: SwapWireframe {

    func present() {
        let vc = wireUp()
        window?.rootViewController = vc
        window?.makeKeyAndVisible()
    }

    func navigate(to destination: SwapWireframeDestination) {
        print("navigate to \(destination)")
    }
}

extension DefaultSwapWireframe {

    private func wireUp() -> UIViewController {
        let vc: SwapViewController = UIStoryboard(.main).instantiate()
        let presenter = DefaultSwapPresenter(
            view: vc,
            interactor: interactor,
            wireframe: self
        )

        vc.presenter = presenter
        return NavigationController(rootViewController: vc)
    }
}
