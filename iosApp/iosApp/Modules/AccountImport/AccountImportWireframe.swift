// Created by web3d3v on 30/12/2023.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

final class DefaultAccountImportWireframe {
    private weak var parent: UIViewController?
    private let context: AccountImportWireframeContext
    private let passwordService: PasswordService
    private let signerStoreService: SignerStoreService
    private let addressService: AddressService
    private let clipboardService: ClipboardService
    private let settingsService: SettingsService

    private weak var vc: UIViewController?

    init(
        _ parent: UIViewController?,
        context: AccountImportWireframeContext,
        signerStoreService: SignerStoreService,
        passwordService: PasswordService,
        clipboardService: ClipboardService,
        settingsService: SettingsService,
        addressService: AddressService
    ) {
        self.parent = parent
        self.context = context
        self.signerStoreService = signerStoreService
        self.passwordService = passwordService
        self.clipboardService = clipboardService
        self.settingsService = settingsService
        self.addressService = addressService
    }
}

extension DefaultAccountImportWireframe {

    func present() {
        let vc = wireUp()
        let presentingTopVc = (parent as? UINavigationController)?.topVc
        if settingsService.themeId == .miami {
            let presentedTopVc = (vc as? UINavigationController)?.topVc
            let delegate = presentedTopVc as? UIViewControllerTransitioningDelegate
            self.vc = vc
            vc.modalPresentationStyle = .overFullScreen
            vc.transitioningDelegate = delegate
        } else {
            vc.modalPresentationStyle = .automatic
        }
        self.vc = vc
        presentingTopVc?.present(vc, animated: true)
    }

    func navigate(to destination: AccountImportWireframeDestination) {
        let presentingTopVc = (parent as? UINavigationController)?.topVc
        if destination is AccountImportWireframeDestination.Dismiss {
            // NOTE: Needs next run loop dispatch so that collectionView has
            // enough time to reload to have target cell for animation
            DispatchQueue.main.async { [weak presentingTopVc] in
                presentingTopVc?.dismiss(animated: true)
            }
        }
    }
}

private extension DefaultAccountImportWireframe {

    func wireUp() -> UIViewController {
        let interactor = DefaultAccountImportInteractor(
            signerStoreService: signerStoreService,
            passwordService: passwordService,
            addressService: addressService,
            clipboardService: clipboardService,
            settingsService: settingsService
        )
        let vc: AccountImportViewController = UIStoryboard(.main).instantiate()
        let presenter = DefaultAccountImportPresenter(
            view: WeakRef(referred: vc),
            wireframe: self,
            interactor: interactor,
            context: context
        )

        vc.presenter = presenter
        let nc = NavigationController(rootViewController: vc)
        self.vc = nc
        return nc
    }
}

extension DefaultAccountImportWireframe {
    enum Constant {
        static let saltExplanationURL = URL(
            string: "https://www.youtube.com/watch?v=XqB5xA62gLw"
        )!
    }
}

