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

    private weak var parent: UIViewController?
    private weak var vc: UIViewController?

    init(
        parent: UIViewController,
        context: AuthenticateContext,
        keyStoreService: KeyStoreService
    ) {
        self.parent = parent
        self.context = context
        self.keyStoreService = keyStoreService
    }
}

// MARK: - AuthenticateWireframe

extension DefaultAuthenticateWireframe: AuthenticateWireframe {

    func present() {
        let interactor = DefaultAuthenticateInteractor(
            keyStoreService: keyStoreService
        )

        if interactor.canUnlockWithBio(context.keyStoreItem) {
            interactor.unlockWithBiometrics(
                context.keyStoreItem,
                title: context.title,
                handler: { result in self.context.handler?(result)}
            )
            return
        }

        let vc = wireUp(interactor)
        self.vc = vc
        parent?.present(vc, animated: true)
    }

    func dismiss() {
        vc?.dismiss(animated: true)
    }
}

extension DefaultAuthenticateWireframe {

    private func wireUp(_ interactor: AuthenticateInteractor) -> UIViewController {
        let vc: AuthenticateViewController = UIStoryboard(.authenticate).instantiate()
        let presenter = DefaultAuthenticatePresenter(
            context: context,
            view: vc,
            interactor: interactor,
            wireframe: self
        )

        vc.presenter = presenter
        let navVc = NavigationController(rootViewController: vc)
        navVc.modalPresentationStyle = .custom
        navVc.transitioningDelegate = vc as? UIViewControllerTransitioningDelegate
        return navVc
    }
}
