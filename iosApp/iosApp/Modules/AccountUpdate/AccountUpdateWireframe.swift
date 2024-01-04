// Created by web3d3v on 31/12/2023.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

final class DefaultAccountUpdateWireframe {
    private weak var parent: UIViewController?
    private let context: AccountUpdateWireframeContext
    private let signerStoreService: SignerStoreService
    private let addressService: AddressService
    private let clipboardService: ClipboardService
    private let settingsService: SettingsService
    private let authenticateWireframeFactory: AuthenticateWireframeFactory
    private let alertWireframeFactory: AlertWireframeFactory

    private weak var vc: UIViewController?

    init(
        _ parent: UIViewController?,
        context: AccountUpdateWireframeContext,
        signerStoreService: SignerStoreService,
        addressService: AddressService,
        clipboardService: ClipboardService,
        settingsService: SettingsService,
        authenticateWireframeFactory: AuthenticateWireframeFactory,
        alertWireframeFactory: AlertWireframeFactory
    ) {
        self.parent = parent
        self.context = context
        self.signerStoreService = signerStoreService
        self.addressService = addressService
        self.clipboardService = clipboardService
        self.settingsService = settingsService
        self.authenticateWireframeFactory = authenticateWireframeFactory
        self.alertWireframeFactory = alertWireframeFactory
    }
}

extension DefaultAccountUpdateWireframe {

    func present() {
        let vc = wireUp()
        let presentingTopVc = (parent as? UINavigationController)?.topVc
        let presentedTopVc = (vc as? UINavigationController)?.topVc
        let delegate = presentedTopVc as? UIViewControllerTransitioningDelegate
        self.vc = vc
        vc.modalPresentationStyle = .overFullScreen
        vc.transitioningDelegate = delegate
        //vc.modalPresentationStyle = .automatic
        presentingTopVc?.present(vc, animated: true)
    }

    func navigate(to destination: AccountUpdateWireframeDestination) {
        if let input = destination as? AccountUpdateWireframeDestination.Authenticate {
            authenticateWireframeFactory.make(vc, context: input.context).present()
        }
        let presentingTopVc = (parent as? UINavigationController)?.topVc
        if destination is AccountUpdateWireframeDestination.Dismiss {
            // NOTE: Dispatching on next run loop so that presenting
            // controller collectionView has time to reload and does not
            // break custom dismiss animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) { [weak presentingTopVc] in
                presentingTopVc?.dismiss(animated: true)
            }
        }
    }
}

private extension DefaultAccountUpdateWireframe {

    func wireUp() -> UIViewController {
        let interactor = DefaultAccountUpdateInteractor(
            signerStoreService: signerStoreService,
            addressService: addressService,
            clipboardService: clipboardService,
            settingsService: settingsService
        )
        let vc: AccountUpdateViewController = UIStoryboard(.main).instantiate()
        let presenter = DefaultAccountUpdatePresenter(
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

extension DefaultAccountUpdateWireframe {

    enum Constant {
        static let saltExplanationURL = URL(
            string: "https://www.youtube.com/watch?v=XqB5xA62gLw"
        )!
    }
}
