// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

enum DashboardWireframeDestination {
    case wallet(wallet: KeyStoreItem, token: Web3Token)
    case keyStoreNetworkSettings
    case presentUnderConstructionAlert
    case mnemonicConfirmation
    case receiveCoins
    case sendCoins
    case nftItem(NFTItem)
    case editTokens(selectedTokens: [Web3Token], onCompletion: ([Web3Token]) -> Void)
}

protocol DashboardWireframe {
    func present()
    func navigate(to destination: DashboardWireframeDestination)
}

final class DefaultDashboardWireframe {

    private weak var parent: UIViewController!
    private weak var vc: UIViewController!

    private let keyStoreService: KeyStoreService
    private let accountWireframeFactory: AccountWireframeFactory
    private let alertWireframeFactory: AlertWireframeFactory
    private let mnemonicConfirmationWireframeFactory: MnemonicConfirmationWireframeFactory
    private let tokenPickerWireframeFactory: TokenPickerWireframeFactory
    private let nftDetailWireframeFactory: NFTDetailWireframeFactory
    private let onboardingService: OnboardingService
    private let web3Service: Web3Service
    private let priceHistoryService: PriceHistoryService
    private let nftsService: NFTsService

    init(
        parent: UIViewController,
        keyStoreService: KeyStoreService,
        accountWireframeFactory: AccountWireframeFactory,
        alertWireframeFactory: AlertWireframeFactory,
        mnemonicConfirmationWireframeFactory: MnemonicConfirmationWireframeFactory,
        tokenPickerWireframeFactory: TokenPickerWireframeFactory,
        nftDetailWireframeFactory: NFTDetailWireframeFactory,
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
            
        case let .wallet(_, token):
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
            
            break
            
        case let .nftItem(nftItem):
            
            nftDetailWireframeFactory.makeWireframe(
                parent,
                context: .init(
                    nftIdentifier: nftItem.identifier,
                    nftCollectionIdentifier: nftItem.collectionIdentifier
                )
            ).present()
            
        case let .editTokens(selectedTokens, onCompletion):
            
            let coordinator = tokenPickerWireframeFactory.makeWireframe(
                presentingIn: parent,
                context: .init(
                    presentationStyle: .present,
                    source: .multiSelectEdit(selectedTokens: selectedTokens, onCompletion: onCompletion)
                )
            )
            coordinator.present()
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
