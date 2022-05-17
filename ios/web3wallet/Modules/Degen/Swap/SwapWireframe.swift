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
    private let dapp: DApp
    private let degenService: DegenService

    init(
        parent: UIViewController,
        dapp: DApp,
        degenService: DegenService
    ) {
        self.parent = parent
        self.dapp = dapp
        self.degenService = degenService
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

private extension DefaultSwapWireframe {

    func wireUp() -> UIViewController {
        
        let interactor = DefaultSwapInteractor(
            dapp: dapp,
            degenService: degenService
        )
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
