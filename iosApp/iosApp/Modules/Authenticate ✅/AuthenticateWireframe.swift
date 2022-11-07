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

extension DefaultAuthenticateWireframe: AuthenticateWireframe {

    func present() {
        let interactor = DefaultAuthenticateInteractor(
            keyStoreService: keyStoreService
        )
        guard let keyStoreItemTarget = keyStoreItemTarget else { return }
        // NOTE: Update keyStoreItem in context to set selected one in case it needs to
        context = .init(
            title: context.title,
            keyStoreItem: keyStoreItemTarget,
            handler: context.handler
        )
        guard !interactor.canUnlockWithBio(keyStoreItem: keyStoreItemTarget) else {
            // NOTE: Passing this as a local variable otherwise in the closure below having a weak self
            // by the time is called back the wireframe is already deallocated and self? is nil.
            let context = context
            interactor.unlockWithBiometrics(
                item: keyStoreItemTarget,
                title: context.title,
                handler: { authData, error in context.handler(authData, error) }
            )
            return
        }

        let vc = wireUp(interactor)
        parent?.present(vc, animated: true)
    }
    
    func navigate(destination________________ destination: AuthenticateWireframeDestination) {
        if destination is AuthenticateWireframeDestination.Dismiss {
            vc?.dismiss(animated: true)
        }
    }

}

private extension DefaultAuthenticateWireframe {
    var keyStoreItemTarget: KeyStoreItem? {
        context.keyStoreItem ?? keyStoreService.selected
    }

    func wireUp(_ interactor: AuthenticateInteractor) -> UIViewController {
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
