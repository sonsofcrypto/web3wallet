// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

final class DefaultMnemonicUpdateWireframe {
    private weak var parent: UIViewController?
    private let context: MnemonicUpdateWireframeContext
    private let keyStoreService: KeyStoreService
    private let authenticateWireframeFactory: AuthenticateWireframeFactory
    private let alertWireframeFactory: AlertWireframeFactory
    private let settingsService: SettingsService

    private weak var vc: UIViewController?

    init(
        _ parent: UIViewController?,
        context: MnemonicUpdateWireframeContext,
        keyStoreService: KeyStoreService,
        authenticateWireframeFactory: AuthenticateWireframeFactory,
        alertWireframeFactory: AlertWireframeFactory,
        settingsService: SettingsService
    ) {
        self.parent = parent
        self.context = context
        self.keyStoreService = keyStoreService
        self.authenticateWireframeFactory = authenticateWireframeFactory
        self.alertWireframeFactory = alertWireframeFactory
        self.settingsService = settingsService
    }
}

extension DefaultMnemonicUpdateWireframe {

    func present() {
        let vc = wireUp()
        let presentingTopVc = (parent as? UINavigationController)?.topVc
        if settingsService.isSelected(setting: .init(group: .developerTransitions, action: .developerTransitionsCardFlip)) {
            let presentedTopVc = (vc as? UINavigationController)?.topVc
            let delegate = presentedTopVc as? UIViewControllerTransitioningDelegate
            self.vc = vc
            vc.modalPresentationStyle = .overFullScreen
            vc.transitioningDelegate = delegate
        } else if settingsService.isSelected(setting: .init(group: .developerTransitions, action: .developerTransitionsSheet)) {
            vc.modalPresentationStyle = .automatic
        }
        presentingTopVc?.present(vc, animated: true)
    }

    func navigate(with destination: MnemonicUpdateWireframeDestination) {
        if let input = destination as? MnemonicUpdateWireframeDestination.Authenticate {
            authenticateWireframeFactory.make(vc, context: input.context).present()
        }
        if let input = destination as? MnemonicUpdateWireframeDestination.Alert {
            alertWireframeFactory.make(vc, context: input.context).present()
        }
        if destination is MnemonicUpdateWireframeDestination.Dismiss {
            // NOTE: Dispatching on next run loop so that presenting
            // controller collectionView has time to reload and does not
            // break custom dismiss animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                [weak self] in self?.vc?.popOrDismiss()
            }
        }
    }
}

private extension DefaultMnemonicUpdateWireframe {

    func wireUp() -> UIViewController {
        let interactor = DefaultMnemonicUpdateInteractor(
            keyStoreService: keyStoreService
        )
        let vc: MnemonicUpdateViewController = UIStoryboard(.mnemonicUpdate).instantiate()
        let presenter = DefaultMnemonicUpdatePresenter(
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

extension DefaultMnemonicUpdateWireframe {

    enum Constant {
        static let saltExplanationURL = URL(
            string: "https://www.youtube.com/watch?v=XqB5xA62gLw"
        )!
    }
}
