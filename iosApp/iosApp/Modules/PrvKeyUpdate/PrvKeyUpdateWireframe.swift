// Created by web3d3v on 31/12/2023.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

final class DefaultPrvKeyUpdateWireframe {
    private weak var parent: UIViewController?
    private let context: PrvKeyUpdateWireframeContext
    private let signerStoreService: SignerStoreService
    private let addressService: AddressService
    private let clipboardService: ClipboardService
    private let settingsService: SettingsService
    private let authenticateWireframeFactory: AuthenticateWireframeFactory
    private let alertWireframeFactory: AlertWireframeFactory

    private weak var vc: UIViewController?

    init(
        _ parent: UIViewController?,
        context: PrvKeyUpdateWireframeContext,
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

extension DefaultPrvKeyUpdateWireframe {

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

    func navigate(to destination: PrvKeyUpdateWireframeDestination) {
        if let input = destination as? PrvKeyUpdateWireframeDestination.Authenticate {
            authenticateWireframeFactory.make(vc, context: input.context).present()
        }
        if let input = destination as? PrvKeyUpdateWireframeDestination.Alert {
            alertWireframeFactory.make(vc, context: input.context).present()
        }
        let presentingTopVc = (parent as? UINavigationController)?.topVc
        if destination is PrvKeyUpdateWireframeDestination.Dismiss {
            // NOTE: Dispatching on next run loop so that presenting
            // controller collectionView has time to reload and does not
            // break custom dismiss animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) { [weak presentingTopVc] in
                presentingTopVc?.dismiss(animated: true)
            }
        }
    }
}

private extension DefaultPrvKeyUpdateWireframe {

    func wireUp() -> UIViewController {
        let interactor = DefaultPrvKeyUpdateInteractor(
            signerStoreService: signerStoreService,
            addressService: addressService,
            clipboardService: clipboardService,
            settingsService: settingsService
        )
        let vc: PrvKeyUpdateViewController = UIStoryboard(.main).instantiate()
        let presenter = DefaultPrvKeyUpdatePresenter(
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

extension DefaultPrvKeyUpdateWireframe {

    enum Constant {
        static let saltExplanationURL = URL(
            string: "https://www.youtube.com/watch?v=XqB5xA62gLw"
        )!
    }
}
