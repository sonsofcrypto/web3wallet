// Created by web3d4v on 04/08/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3lib

struct NFTSendWireframeContext {
    
    let presentationStyle: PresentationStyle
    let nftItem: NFTItem
    let network: Web3Network
}

enum NFTSendWireframeDestination {
    
    case underConstructionAlert
    case qrCodeScan(network: Network, onCompletion: (String) -> Void)
    case confirmSendNFT(
        dataIn: ConfirmationWireframeContext.SendNFTContext
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
    private let alertWireframeFactory: AlertWireframeFactory
    private let web3Service: Web3ServiceLegacy
    private let networksService: NetworksService
    
    private weak var navigationController: NavigationController!
    
    init(
        presentingIn: UIViewController,
        context: NFTSendWireframeContext,
        qrCodeScanWireframeFactory: QRCodeScanWireframeFactory,
        confirmationWireframeFactory: ConfirmationWireframeFactory,
        alertWireframeFactory: AlertWireframeFactory,
        web3Service: Web3ServiceLegacy,
        networksService: NetworksService
    ) {
        self.presentingIn = presentingIn
        self.context = context
        self.qrCodeScanWireframeFactory = qrCodeScanWireframeFactory
        self.confirmationWireframeFactory = confirmationWireframeFactory
        self.alertWireframeFactory = alertWireframeFactory
        self.web3Service = web3Service
        self.networksService = networksService
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
            factory.make(
                navigationController,
                context: .underConstructionAlert()
            ).present()
        case let .qrCodeScan(network, onCompletion):
            qrCodeScanWireframeFactory.make(
                navigationController,
                context: .init(type: .network(network), onCompletion: onCompletion)
            ).present()
        case let .confirmSendNFT(dataIn):
            guard dataIn.addressFrom != dataIn.addressTo else {
                return presentSendingToSameAddressAlert()
            }
            confirmationWireframeFactory.make(
                navigationController.topViewController,
                context: .init(type: .sendNFT(dataIn))
            ).present()
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
            web3Service: web3Service,
            networksService: networksService
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
    
    func presentSendingToSameAddressAlert() {
        alertWireframeFactory.make(
            navigationController,
            context: .init(
                title: Localized("alert.send.transaction.toYourself.title"),
                media: .image(named: "hand.raised", size: .init(length: 40)),
                message: Localized("alert.send.transaction.toYourself.message"),
                actions: [
                    .init(title: Localized("Ok"), type: .primary, action: nil)
                ],
                contentHeight: 230
            )
        ).present()
    }
}
