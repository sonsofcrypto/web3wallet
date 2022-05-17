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

final class DefaultAMMsWireframe {

    private weak var parent: UIViewController?
    private weak var vc: UIViewController?

    private let interactor: AMMsInteractor
    private let swapWireframeFactory: SwapWireframeFactory

    init(
        parent: UIViewController,
        interactor: AMMsInteractor,
        swapWireframeFactory: SwapWireframeFactory
    ) {
        self.parent = parent
        self.interactor = interactor
        self.swapWireframeFactory = swapWireframeFactory
    }
}

// MARK: - AMMsWireframe

extension DefaultAMMsWireframe: AMMsWireframe {

    func present() {
        let vc = wireUp()
        self.vc = vc
        parent?.show(vc, sender: self)

    }

    func navigate(to destination: AMMsWireframeDestination) {
        guard let vc = self.vc else {
            print("DefaultAMMsWireframe does not have a view")
            return
        }

        switch destination {
        case let .dapp(dapp):
            swapWireframeFactory.makeWireframe(vc, dapp: dapp).present()

        default:
            fatalError("Navigation to \(destination) not implemented")
        }
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
