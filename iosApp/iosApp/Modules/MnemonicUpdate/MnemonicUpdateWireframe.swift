// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3lib

enum MnemonicUpdateWireframeDestination {
    case authenticate(context: AuthenticateContext)
    case learnMoreSalt
    case confirmationAlert(onConfirm: TargetActionViewModel)
    case dismiss
}

protocol MnemonicUpdateWireframe {
    func present()
    func navigate(to destination: MnemonicUpdateWireframeDestination)
}

final class DefaultMnemonicUpdateWireframe {
    private weak var parent: UIViewController?
    private let context: MnemonicUpdateContext
    private let keyStoreService: KeyStoreService
    private let authenticateWireframeFactory: AuthenticateWireframeFactory
    private let alertWireframeFactory: AlertWireframeFactory
    private let settingsService: SettingsService

    private weak var vc: UIViewController?

    init(
        _ parent: UIViewController?,
        context: MnemonicUpdateContext,
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

extension DefaultMnemonicUpdateWireframe: MnemonicUpdateWireframe {

    func present() {
        let vc = wireUp()
        let presentingTopVc = (parent as? UINavigationController)?.topVc
        if settingsService.isSelected(item: .debugTransitions, action: .debugTransitionsCardFlip) {
            let presentedTopVc = (vc as? UINavigationController)?.topVc
            let delegate = presentedTopVc as? UIViewControllerTransitioningDelegate
            self.vc = vc
            vc.modalPresentationStyle = .overFullScreen
            vc.transitioningDelegate = delegate
        } else if settingsService.isSelected(item: .debugTransitions, action: .debugTransitionsSheet) {
            vc.modalPresentationStyle = .automatic
        }
        presentingTopVc?.present(vc, animated: true)
    }

    func navigate(to destination: MnemonicUpdateWireframeDestination) {
        switch destination {
        case .learnMoreSalt:
            UIApplication.shared.open(Constant.saltExplanationURL)
        case let .authenticate(context):
            authenticateWireframeFactory.make(
                vc,
                context: context
            ).present()
        case let .confirmationAlert(onConfirm):
            alertWireframeFactory.make(
                vc,
                context: deleteConfirmationAlertContext(with: onConfirm)
            ).present()
        case .dismiss:
            vc?.popOrDismiss()
        }
    }
}

private extension DefaultMnemonicUpdateWireframe {

    func wireUp() -> UIViewController {
        let interactor = DefaultMnemonicUpdateInteractor(
            keyStoreService
        )
        let vc: MnemonicUpdateViewController = UIStoryboard(.mnemonicUpdate).instantiate()
        let presenter = DefaultMnemonicUpdatePresenter(
            view: vc,
            wireframe: self,
            interactor: interactor,
            context: context
        )
        vc.presenter = presenter
        let nc = NavigationController(rootViewController: vc)
        self.vc = nc
        return nc
    }
    
    func deleteConfirmationAlertContext(with onConfirm: TargetActionViewModel) -> AlertContext {
        .init(
            title: Localized("alert.deleteWallet.title"),
            media: nil,
            message: Localized("alert.deleteWallet.message"),
            actions: [
                .init(
                    title: Localized("alert.deleteWallet.action.confirm"),
                    type: .destructive,
                    action: onConfirm
                ),
                .init(
                    title: Localized("cancel"),
                    type: .secondary,
                    action: nil
                )
            ],
            contentHeight: 350
        )
    }
}

extension DefaultMnemonicUpdateWireframe {

    enum Constant {
        static let saltExplanationURL = URL(
            string: "https://www.youtube.com/watch?v=XqB5xA62gLw"
        )!
    }
}

