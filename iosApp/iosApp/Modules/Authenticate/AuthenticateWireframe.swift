// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3lib

protocol AuthenticateWireframe {
    func present()
    func dismiss()
}

// MARK: - DefaultAuthenticateWireframe

class DefaultAuthenticateWireframe {

    private let context: AuthenticateContext
    private let keyStoreService: KeyStoreService
    private let keyChainService: KeyChainService

    private weak var parent: UIViewController?
    private weak var vc: UIViewController?

    init(
        parent: UIViewController,
        context: AuthenticateContext,
        keyStoreService: KeyStoreService,
        keyChainService: KeyChainService
    ) {
        self.parent = parent
        self.context = context
        self.keyStoreService = keyStoreService
        self.keyChainService = keyChainService
    }
}

// MARK: - AuthenticateWireframe

extension DefaultAuthenticateWireframe: AuthenticateWireframe {

    func present() {
        let vc = wireUp()
        // TODO: Check if key chain will suffice
        self.vc = vc
        parent?.present(vc, animated: true)
    }

    func dismiss() {
        vc?.dismiss(animated: true)
    }
}

extension DefaultAuthenticateWireframe {

    private func wireUp() -> UIViewController {
        let vc: AuthenticateViewController = UIStoryboard(.authenticate).instantiate()
        let presenter = DefaultAuthenticatePresenter(
            context: context,
            view: vc,
            interactor: DefaultAuthenticateInteractor(
                keyStoreService: keyStoreService,
                keyChainService: keyChainService
            ),
            wireframe: self
        )

        vc.presenter = presenter
        return NavigationController(rootViewController: vc)
    }
}
