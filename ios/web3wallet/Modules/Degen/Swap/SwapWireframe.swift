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

final class DefaultSwapWireframe {

    private weak var parent: UIViewController?

    private let interactor: SwapInteractor

    init(
        parent: UIViewController,
        interactor: SwapInteractor
    ) {
        self.parent = parent
        self.interactor = interactor
    }
}

// MARK: - SwapWireframe

extension DefaultSwapWireframe: SwapWireframe {

    func present() {
        let vc = wireUp()
        parent?.show(vc, sender: self)
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
        return vc
    }
}
