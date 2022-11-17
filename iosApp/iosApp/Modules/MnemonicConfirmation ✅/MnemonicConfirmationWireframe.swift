// Created by web3d4v on 12/05/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

final class DefaultMnemonicConfirmationWireframe {
    private weak var parent: UIViewController?
    private let keyStoreService: KeyStoreService
    private let actionsService: ActionsService
    private let networksService: NetworksService
    
    private weak var vc: UIViewController?

    init(
        _ parent: UIViewController?,
        keyStoreService: KeyStoreService,
        actionsService: ActionsService,
        networksService: NetworksService
    ) {
        self.parent = parent
        self.keyStoreService = keyStoreService
        self.actionsService = actionsService
        self.networksService = networksService
    }
}

extension DefaultMnemonicConfirmationWireframe {

    func present() {
        let vc = wireUp()
        parent?.present(vc, animated: true)
    }
    
    func navigate(with destination: MnemonicConfirmationWireframeDestination) {
        if destination is MnemonicConfirmationWireframeDestination.Dismiss {
            vc?.popOrDismiss()
        }
    }
}

private extension DefaultMnemonicConfirmationWireframe {

    func wireUp() -> UIViewController {
        let interactor = DefaultMnemonicConfirmationInteractor(
            keyStoreService: keyStoreService,
            actionsService: actionsService,
            networksService: networksService
        )
        let vc: MnemonicConfirmationViewController = UIStoryboard(.mnemonicConfirmation).instantiate()
        let presenter = DefaultMnemonicConfirmationPresenter(
            view: WeakRef(referred: vc),
            wireframe: self,
            interactor: interactor
        )
        vc.presenter = presenter
        let nc = NavigationController(rootViewController: vc)
        self.vc = nc
        return nc
    }
}
