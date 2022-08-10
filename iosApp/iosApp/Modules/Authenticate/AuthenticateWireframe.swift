// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3lib

protocol AuthenticateWireframe {
    func present()
    func dismiss()
}

final class DefaultAuthenticateWireframe {

    private weak var parent: UIViewController?
    private var context: AuthenticateContext
    private let keyStoreService: KeyStoreService

    private weak var navVc: NavigationController?

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

        guard
            !interactor.canUnlockWithBio(keyStoreItemTarget)
        else {
            
            interactor.unlockWithBiometrics(
                keyStoreItemTarget,
                title: context.title,
                handler: { [weak self] result in self?.context.handler(result)}
            )
            return
        }

        let vc = wireUp(interactor)
        parent?.present(vc, animated: true)
    }

    func dismiss() {
        navVc?.dismiss(animated: true)
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
            context: context,
            interactor: interactor,
            wireframe: self
        )

        vc.presenter = presenter
        let navVc = NavigationController(rootViewController: vc)
        navVc.modalPresentationStyle = .custom
        navVc.transitioningDelegate = vc
        self.navVc = navVc
        return navVc
    }
}
