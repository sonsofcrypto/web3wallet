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

    private weak var parent: UIViewController!
    private let context: MnemonicUpdateContext
    private let keyStoreService: KeyStoreService
    private let authenticateWireframeFactory: AuthenticateWireframeFactory
    private let alertWireframeFactory: AlertWireframeFactory

    private weak var vc: UIViewController!

    init(
        parent: UIViewController?,
        context: MnemonicUpdateContext,
        keyStoreService: KeyStoreService,
        authenticateWireframeFactory: AuthenticateWireframeFactory,
        alertWireframeFactory: AlertWireframeFactory
    ) {
        self.parent = parent
        self.context = context
        self.keyStoreService = keyStoreService
        self.authenticateWireframeFactory = authenticateWireframeFactory
        self.alertWireframeFactory = alertWireframeFactory
    }
}

extension DefaultMnemonicUpdateWireframe: MnemonicUpdateWireframe {

    func present() {
        
        let vc = wireUp()
        let topVc = (parent as? UINavigationController)?.topViewController

        if let transitionDelegate =  topVc as? UIViewControllerTransitioningDelegate {
            vc.transitioningDelegate = transitionDelegate
        }

        switch ServiceDirectory.transitionStyle {
        case .cardFlip:
            vc.modalPresentationStyle = .overCurrentContext
        case .sheet:
            vc.modalPresentationStyle = .automatic
        }

        self.vc = vc
        topVc?.show(vc, sender: self)
    }

    func navigate(to destination: MnemonicUpdateWireframeDestination) {
        
        switch destination {
            
        case .learnMoreSalt:
            
            UIApplication.shared.open(Constant.saltExplanationURL)
            
        case let .authenticate(context):
            
            authenticateWireframeFactory.makeWireframe(
                vc,
                context: context
            ).present()
            
        case let .confirmationAlert(onConfirm):
            
            alertWireframeFactory.makeWireframe(
                vc,
                context: makeDeleteConfirmationAlertContext(with: onConfirm)
            ).present()
            
        case .dismiss:
            
            vc.dismiss(animated: true)
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
            context: context,
            view: vc,
            interactor: interactor,
            wireframe: self
        )

        vc.presenter = presenter
        return NavigationController(rootViewController: vc)
    }
    
    func makeDeleteConfirmationAlertContext(with onConfirm: TargetActionViewModel) -> AlertContext {
        
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
                    title: Localized("alert.deleteWallet.action.cancel"),
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

