// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

enum AMMsWireframeDestination {
    case dapp(DApp)
}

protocol AMMsWireframe {
    func present()
    func navigate(to destination: AMMsWireframeDestination)
}

// MARK: - DefaultAMMsWireframe

class DefaultAMMsWireframe {

    private let interactor: AMMsInteractor

    private weak var parent: UIViewController?

    init(
        parent: UIViewController,
        interactor: AMMsInteractor
    ) {
        self.parent = parent
        self.interactor = interactor
    }
}

// MARK: - AMMsWireframe

extension DefaultAMMsWireframe: AMMsWireframe {

    func present() {
        let vc = wireUp()
        parent?.show(vc, sender: self)

    }

    func navigate(to destination: AMMsWireframeDestination) {
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
        return vc
    }
}
