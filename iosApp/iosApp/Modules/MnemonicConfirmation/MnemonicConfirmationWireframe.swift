// Created by web3d4v on 12/05/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

final class DefaultMnemonicConfirmationWireframe {
    private weak var parent: UIViewController?
    private let keyStoreService: KeyStoreService
    private let actionsService: ActionsService
    private let mnemonicService: MnemonicService
    
    private weak var vc: UIViewController?

    init(
        _ parent: UIViewController?,
        keyStoreService: KeyStoreService,
        actionsService: ActionsService,
        mnemonicService: MnemonicService
    ) {
        self.parent = parent
        self.keyStoreService = keyStoreService
        self.actionsService = actionsService
        self.mnemonicService = mnemonicService
    }
}

extension DefaultMnemonicConfirmationWireframe {

    func present() {
        let vc = wireUp()
        parent?.present(vc, animated: true)
    }
    
    func navigate(to destination: MnemonicConfirmationWireframeDestination) {
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
            mnemonicService: mnemonicService
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
