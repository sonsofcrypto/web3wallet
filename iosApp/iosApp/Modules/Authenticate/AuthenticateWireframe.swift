// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

final class DefaultAuthenticateWireframe {
    private weak var parent: UIViewController?
    private var context: AuthenticateWireframeContext
    private let keyStoreService: KeyStoreService

    private weak var vc: UIViewController?

    init(
        _ parent: UIViewController?,
        context: AuthenticateWireframeContext,
        keyStoreService: KeyStoreService
    ) {
        self.parent = parent
        self.context = context
        self.keyStoreService = keyStoreService
    }
}

extension DefaultAuthenticateWireframe {

    func present() {
        let vc = wireUp()
        parent?.present(vc, animated: true)
    }
    
    func navigate(with destination: AuthenticateWireframeDestination) {
        if destination is AuthenticateWireframeDestination.Dismiss {
            vc?.dismiss(animated: true)
        }
    }

}

private extension DefaultAuthenticateWireframe {

    func wireUp() -> UIViewController {
        let interactor = DefaultAuthenticateInteractor(
            keyStoreService: keyStoreService
        )
        let vc: AuthenticateViewController = UIStoryboard(.authenticate).instantiate()
        let presenter = DefaultAuthenticatePresenter(
            view: WeakRef(referred: vc),
            wireframe: self,
            interactor: interactor,
            context: context
        )
        vc.presenter = presenter
        let nc = NavigationController(rootViewController: vc)
        nc.modalPresentationStyle = .custom
        nc.transitioningDelegate = vc
        self.vc = nc
        return nc
    }
}
