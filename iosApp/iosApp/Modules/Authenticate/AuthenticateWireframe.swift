// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

protocol AuthenticateWireframe {
    func present()
    func dismiss()
}

final class DefaultAuthenticateWireframe {
    private weak var parent: UIViewController?
    private var context: AuthenticateContext
    private let keyStoreService: KeyStoreService

    private weak var vc: UIViewController?

    init(
        _ parent: UIViewController?,
        context: AuthenticateContext,
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
        guard !interactor.canUnlockWithBio(keyStoreItemTarget) else {
            // NOTE: Passing this as a local variable otherwise in the closure below having a weak self
            // by the time is called back the wireframe is already deallocated and self? is nil.
            let context = context
            interactor.unlockWithBiometrics(
                keyStoreItemTarget,
                title: context.title,
                handler: { result in
                    context.handler(result)}
            )
            return
        }

        let vc = wireUp(interactor)
        parent?.present(vc, animated: true)
    }

    func dismiss() {
        vc?.dismiss(animated: true)
    }
}

private extension DefaultAuthenticateWireframe {
    var keyStoreItemTarget: KeyStoreItem? {
        context.keyStoreItem ?? keyStoreService.selected
    }

    func wireUp(_ interactor: AuthenticateInteractor) -> UIViewController {
        let vc: AuthenticateViewController = UIStoryboard(.authenticate).instantiate()
        let presenter = DefaultAuthenticatePresenter(
            view: vc,
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
