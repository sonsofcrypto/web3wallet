// Created by web3d4v on 04/08/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

struct NFTSendWireframeContext {
    
    let presentationStyle: PresentationStyle
    let nftItem: NFTItem
    let network: Web3Network
}

enum NFTSendWireframeDestination {
    
    case underConstructionAlert
    case qrCodeScan(network: Web3Network, onCompletion: (String) -> Void)
    case confirmSendNFT(
        dataIn: ConfirmationWireframeContext.SendNFTContext,
        onSuccess: () -> Void
    )
}

protocol NFTSendWireframe {
    func present()
    func navigate(to destination: NFTSendWireframeDestination)
    func dismiss()
}

final class DefaultNFTSendWireframe {
    
    private weak var presentingIn: UIViewController!
    private let context: NFTSendWireframeContext
    private let qrCodeScanWireframeFactory: QRCodeScanWireframeFactory
    private let confirmationWireframeFactory: ConfirmationWireframeFactory
    private let web3Service: Web3ServiceLegacy
    
    private weak var navigationController: NavigationController!
    
    init(
        presentingIn: UIViewController,
        context: NFTSendWireframeContext,
        qrCodeScanWireframeFactory: QRCodeScanWireframeFactory,
        confirmationWireframeFactory: ConfirmationWireframeFactory,
        web3Service: Web3ServiceLegacy
    ) {
        self.presentingIn = presentingIn
        self.context = context
        self.qrCodeScanWireframeFactory = qrCodeScanWireframeFactory
        self.confirmationWireframeFactory = confirmationWireframeFactory
        self.web3Service = web3Service
    }
}

extension DefaultNFTSendWireframe: NFTSendWireframe {
    
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
    
    func navigate(to destination: NFTSendWireframeDestination) {
        
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
            
        case let .confirmSendNFT(dataIn, onSuccess):
            
            guard let viewController = navigationController.topViewController else {
                
                return
            }
            
            let wireframe = confirmationWireframeFactory.makeWireframe(
                presentingIn: viewController,
                context: .init(type: .sendNFT(dataIn), onSuccessHandler: onSuccess)
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

private extension DefaultNFTSendWireframe {
    
    func wireUp() -> UIViewController {
        
        let interactor = DefaultNFTSendInteractor(
            web3Service: web3Service
        )
        let vc: NFTSendViewController = UIStoryboard(.nftSend).instantiate()
        let presenter = DefaultNFTSendPresenter(
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
