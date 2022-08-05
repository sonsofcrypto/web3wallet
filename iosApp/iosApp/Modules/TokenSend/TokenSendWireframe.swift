// Created by web3d4v on 06/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

struct TokenSendWireframeContext {
    let presentationStyle: PresentationStyle
    let web3Token: Web3Token?
}

enum TokenSendWireframeDestination {
    
    case underConstructionAlert
    case qrCodeScan(network: Web3Network, onCompletion: (String) -> Void)
    case selectToken(onCompletion: (Web3Token) -> Void)
    case confirmSend(
        dataIn: ConfirmationWireframeContext.SendContext,
        onSuccess: () -> Void
    )
}

protocol TokenSendWireframe {
    func present()
    func navigate(to destination: TokenSendWireframeDestination)
    func dismiss()
}

final class DefaultTokenSendWireframe {
    
    private weak var presentingIn: UIViewController!
    private let context: TokenSendWireframeContext
    private let qrCodeScanWireframeFactory: QRCodeScanWireframeFactory
    private let tokenPickerWireframeFactory: TokenPickerWireframeFactory
    private let confirmationWireframeFactory: ConfirmationWireframeFactory
    private let web3Service: Web3ServiceLegacy
    
    private weak var navigationController: NavigationController!
    
    init(
        presentingIn: UIViewController,
        context: TokenSendWireframeContext,
        qrCodeScanWireframeFactory: QRCodeScanWireframeFactory,
        tokenPickerWireframeFactory: TokenPickerWireframeFactory,
        confirmationWireframeFactory: ConfirmationWireframeFactory,
        web3Service: Web3ServiceLegacy
    ) {
        self.presentingIn = presentingIn
        self.context = context
        self.qrCodeScanWireframeFactory = qrCodeScanWireframeFactory
        self.tokenPickerWireframeFactory = tokenPickerWireframeFactory
        self.confirmationWireframeFactory = confirmationWireframeFactory
        self.web3Service = web3Service
    }
}

extension DefaultTokenSendWireframe: TokenSendWireframe {
    
    func present() {
        let vc = wireUp()
        switch context.presentationStyle {
        case .embed:
            fatalError("This module should not be presented embedded")
        case .present:
            presentingIn.present(vc, animated: true)
        case .push:
            guard let presentingIn = presentingIn as? NavigationController else { return }
            presentingIn.pushViewController(vc, animated: true)
        }
    }
    
    func navigate(to destination: TokenSendWireframeDestination) {
        
        switch destination {
        case .underConstructionAlert:
            let factory: AlertWireframeFactory = ServiceDirectory.assembler.resolve()
            factory.makeWireframe(
                navigationController,
                context: .underConstructionAlert()
            ).present()
            
        case let .qrCodeScan(network, onCompletion):
            let wireframe = qrCodeScanWireframeFactory.makeWireframe(
                presentingIn: navigationController,
                context: .init(
                    presentationStyle: .push,
                    type: .network(network),
                    onCompletion: onCompletion
                )
            )
            wireframe.present()
            
        case let .selectToken(onCompletion):
            let wireframe = tokenPickerWireframeFactory.makeWireframe(
                presentingIn: navigationController,
                context: .init(
                    presentationStyle: .present,
                    source: .select(
                        onCompletion: onCompletion
                    )
                )
            )
            wireframe.present()
            
        case let .confirmSend(dataIn, onSuccess):
            guard let viewController = navigationController.topViewController else {
                return
            }
            
            let wireframe = confirmationWireframeFactory.makeWireframe(
                presentingIn: viewController,
                context: .init(type: .send(dataIn), onSuccessHandler: onSuccess)
            )
            wireframe.present()
        }
    }
    
    func dismiss() {
        if navigationController.viewControllers.count == 1 {
            navigationController.dismiss(animated: true)
        } else {
            navigationController.popViewController(animated: true)
        }
    }
}

private extension DefaultTokenSendWireframe {
    
    func wireUp() -> UIViewController {
        
        let interactor = DefaultTokenSendInteractor(
            web3Service: web3Service
        )
        let vc: TokenSendViewController = UIStoryboard(.tokenSend).instantiate()
        let presenter = DefaultTokenSendPresenter(
            view: vc,
            interactor: interactor,
            wireframe: self,
            context: context
        )
        vc.hidesBottomBarWhenPushed = true
        vc.presenter = presenter
        
        switch context.presentationStyle {
        case .embed:
            fatalError("This module should not be presented embedded")
        case .present:
            vc.hidesBottomBarWhenPushed = true
            let navigationController = NavigationController(rootViewController: vc)
            self.navigationController = navigationController
            return navigationController

        case .push:
            vc.hidesBottomBarWhenPushed = true
            if let navigationController = presentingIn as? NavigationController {
                self.navigationController = navigationController
                return vc
            }
            
            let navigationController = NavigationController(rootViewController: vc)
            self.navigationController = navigationController
            return navigationController
        }
    }
}
