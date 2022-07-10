// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

enum DashboardWireframeDestination {
    case wallet(token: Web3Token)
    case keyStoreNetworkSettings
    case presentUnderConstructionAlert
    case mnemonicConfirmation
    case receiveCoins
    case sendCoins
    case scanQRCode(onCompletion: (String) -> Void)
    case nftItem(NFTItem)
    case editTokens(
        network: Web3Network,
        selectedTokens: [Web3Token],
        onCompletion: ([Web3Token]) -> Void
    )
}

protocol DashboardWireframe {
    func present()
    func navigate(to destination: DashboardWireframeDestination)
}

final class DefaultDashboardWireframe {

    private weak var parent: UIViewController!
    private weak var vc: UIViewController!

    private let keyStoreService: OldKeyStoreService
    private let accountWireframeFactory: AccountWireframeFactory
    private let alertWireframeFactory: AlertWireframeFactory
    private let mnemonicConfirmationWireframeFactory: MnemonicConfirmationWireframeFactory
    private let tokenPickerWireframeFactory: TokenPickerWireframeFactory
    private let nftDetailWireframeFactory: NFTDetailWireframeFactory
    private let qrCodeScanWireframeFactory: QRCodeScanWireframeFactory
    private let onboardingService: OnboardingService
    private let web3Service: Web3Service
    private let priceHistoryService: PriceHistoryService
    private let nftsService: NFTsService

    init(
        parent: UIViewController,
        keyStoreService: OldKeyStoreService,
        accountWireframeFactory: AccountWireframeFactory,
        alertWireframeFactory: AlertWireframeFactory,
        mnemonicConfirmationWireframeFactory: MnemonicConfirmationWireframeFactory,
        tokenPickerWireframeFactory: TokenPickerWireframeFactory,
        nftDetailWireframeFactory: NFTDetailWireframeFactory,
        qrCodeScanWireframeFactory: QRCodeScanWireframeFactory,
        onboardingService: OnboardingService,
        web3Service: Web3Service,
        priceHistoryService: PriceHistoryService,
        nftsService: NFTsService
    ) {
        self.parent = parent
        self.keyStoreService = keyStoreService
        self.accountWireframeFactory = accountWireframeFactory
        self.alertWireframeFactory = alertWireframeFactory
        self.mnemonicConfirmationWireframeFactory = mnemonicConfirmationWireframeFactory
        self.tokenPickerWireframeFactory = tokenPickerWireframeFactory
        self.nftDetailWireframeFactory = nftDetailWireframeFactory
        self.qrCodeScanWireframeFactory = qrCodeScanWireframeFactory
        self.onboardingService = onboardingService
        self.web3Service = web3Service
        self.priceHistoryService = priceHistoryService
        self.nftsService = nftsService
    }
}

extension DefaultDashboardWireframe: DashboardWireframe {

    func present() {
        
        vc = wireUp()
        
        if let parent = parent as? EdgeCardsController {
            
            parent.setMaster(vc: vc)
        
        } else if let tabVc = parent as? UITabBarController {
            
            let vcs: [UIViewController] = [vc] + (tabVc.viewControllers ?? [])
            tabVc.setViewControllers(vcs, animated: false)
            
        } else {
            parent.show(vc, sender: self)
        }
    }

    func navigate(to destination: DashboardWireframeDestination) {
        guard let vc = self.vc ?? parent else {
            print("DefaultDashboardWireframe has no view")
            return
        }

        switch destination {
            
        case let .wallet(token):
            accountWireframeFactory.makeWireframe(
                presentingIn: vc, context: .init(web3Token: token)
            ).present()
            
        case .keyStoreNetworkSettings:
            vc.edgeCardsController?.setDisplayMode(.overview, animated: true)
            
        case .presentUnderConstructionAlert:
            
            let context = AlertContext.underConstructionAlert()
            alertWireframeFactory.makeWireframe(parent, context: context).present()
            
        case .mnemonicConfirmation:
            
            mnemonicConfirmationWireframeFactory.makeWireframe(parent).present()
            
        case .receiveCoins:
            
            presentTokenPicker(with: .receive)
            
        case .sendCoins:
            
            presentTokenPicker(with: .send)
            
        case let .scanQRCode(onCompletion):
            
            let wireframe = qrCodeScanWireframeFactory.makeWireframe(
                presentingIn: parent,
                context: .init(
                    presentationStyle: .present,
                    type: .default,
                    onCompletion: onCompletion
                )
            )
            wireframe.present()
            
        case let .nftItem(nftItem):
            
            nftDetailWireframeFactory.makeWireframe(
                parent,
                context: .init(
                    nftIdentifier: nftItem.identifier,
                    nftCollectionIdentifier: nftItem.collectionIdentifier
                )
            ).present()
            
        case let .editTokens(network, selectedTokens, onCompletion):
            
            let source: TokenPickerWireframeContext.Source = .multiSelectEdit(
                network: network,
                selectedTokens: selectedTokens,
                onCompletion: onCompletion
            )
            let wireframe = tokenPickerWireframeFactory.makeWireframe(
                presentingIn: parent,
                context: .init(
                    presentationStyle: .present,
                    source: source
                )
            )
            wireframe.present()
        }
    }
}

private extension DefaultDashboardWireframe {

    func wireUp() -> UIViewController {
        
        let interactor = DefaultDashboardInteractor(
            web3Service: web3Service,
            priceHistoryService: priceHistoryService,
            nftsService: nftsService
        )
        let vc: DashboardViewController = UIStoryboard(.dashboard).instantiate()
        let presenter = DefaultDashboardPresenter(
            view: vc,
            interactor: interactor,
            wireframe: self,
            onboardingService: onboardingService
        )
        vc.presenter = presenter
        return NavigationController(rootViewController: vc)
    }
    
    func presentTokenPicker(
        with source: TokenPickerWireframeContext.Source
    ) {
        
        let factory: TokenPickerWireframeFactory = ServiceDirectory.assembler.resolve()
        let context = TokenPickerWireframeContext(
            presentationStyle: .present,
            source: source
        )
        factory.makeWireframe(
            presentingIn: parent,
            context: context
        ).present()
    }
}
