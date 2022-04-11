// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

enum NewMnemonicWireframeDestination {

}

protocol NewMnemonicWireframe {
    func present()
    func navigate(to destination: NewMnemonicWireframeDestination)
}

// MARK: - class DefaultNewMnemonicWireframe {

class DefaultNewMnemonicWireframe {

    private let interactor: NewMnemonicInteractor

    private weak var parent: UIViewController?
    private weak var vc: UIViewController?

    init(
        parent: UIViewController?,
        interactor: NewMnemonicInteractor
    ) {
        self.interactor = interactor
        self.parent = parent
    }
}

// MARK: - NewMnemonicWireframe

extension DefaultNewMnemonicWireframe: NewMnemonicWireframe {

    func present() {
        let vc = wireUp()
        self.vc = vc
        parent?.show(vc, sender: self)
    }

    func navigate(to destination: NewMnemonicWireframeDestination) {
        print("navigate to \(destination)")
    }
}

extension DefaultNewMnemonicWireframe {

    private func wireUp() -> UIViewController {
        let vc: NewMnemonicViewController = UIStoryboard(.main).instantiate()
        let presenter = DefaultNewMnemonicPresenter(
            view: vc,
            interactor: interactor,
            wireframe: self
        )

        vc.presenter = presenter
        return NavigationController(rootViewController: vc)
    }
}
