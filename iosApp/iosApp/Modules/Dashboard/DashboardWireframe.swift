// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3lib

enum DashboardWireframeDestination {
    case wallet(wallet: Wallet, currency: Currency)
    case keyStoreNetworkSettings
    case presentUnderConstructionAlert
    case mnemonicConfirmation
    case receive
    case send(addressTo: String?)
    case scanQRCode(onCompletion: (String) -> Void)
    case nftItem(NFTItem)
    case editTokens(
        network: Web3Network,
        selectedTokens: [Web3Token],
        onCompletion: ([Web3Token]) -> Void
    )
    case tokenSwap
    case deepLink(DeepLink)
    case themePicker
}

protocol DashboardWireframe {
    func present()
    func navigate(to destination: DashboardWireframeDestination)
}

final class DefaultDashboardWireframe {

    private weak var parent: UIViewController!
    private weak var vc: UIViewController!

    private let accountWireframeFactory: AccountWireframeFactory
    private let alertWireframeFactory: AlertWireframeFactory
    private let mnemonicConfirmationWireframeFactory: MnemonicConfirmationWireframeFactory
    private let tokenPickerWireframeFactory: TokenPickerWireframeFactory
    private let tokenReceiveWireframeFactory: TokenReceiveWireframeFactory
    private let tokenSendWireframeFactory: TokenSendWireframeFactory
    private let tokenSwapWireframeFactory: TokenSwapWireframeFactory
    private let nftDetailWireframeFactory: NFTDetailWireframeFactory
    private let qrCodeScanWireframeFactory: QRCodeScanWireframeFactory
    private let themePickerWireframeFactory: ThemePickerWireframeFactory
    private let onboardingService: OnboardingService
    private let deepLinkHandler: DeepLinkHandler
    private let networksService: NetworksService
    private let currencyStoreService: CurrencyStoreService
    private let walletService: WalletService
    private let nftsService: NFTsService
    
    private weak var navigationController: NavigationController!

    init(
        parent: UIViewController,
        accountWireframeFactory: AccountWireframeFactory,
        alertWireframeFactory: AlertWireframeFactory,
        mnemonicConfirmationWireframeFactory: MnemonicConfirmationWireframeFactory,
        tokenPickerWireframeFactory: TokenPickerWireframeFactory,
        tokenReceiveWireframeFactory: TokenReceiveWireframeFactory,
        tokenSendWireframeFactory: TokenSendWireframeFactory,
        tokenSwapWireframeFactory: TokenSwapWireframeFactory,
        nftDetailWireframeFactory: NFTDetailWireframeFactory,
        qrCodeScanWireframeFactory: QRCodeScanWireframeFactory,
        themePickerWireframeFactory: ThemePickerWireframeFactory,
        onboardingService: OnboardingService,
        deepLinkHandler: DeepLinkHandler,
        networksService: NetworksService,
        currencyStoreService: CurrencyStoreService,
        walletService: WalletService,
        nftsService: NFTsService
    ) {
        self.parent = parent
        self.accountWireframeFactory = accountWireframeFactory
        self.alertWireframeFactory = alertWireframeFactory
        self.mnemonicConfirmationWireframeFactory = mnemonicConfirmationWireframeFactory
        self.tokenPickerWireframeFactory = tokenPickerWireframeFactory
        self.tokenReceiveWireframeFactory = tokenReceiveWireframeFactory
        self.tokenSendWireframeFactory = tokenSendWireframeFactory
        self.tokenSwapWireframeFactory = tokenSwapWireframeFactory
        self.nftDetailWireframeFactory = nftDetailWireframeFactory
        self.qrCodeScanWireframeFactory = qrCodeScanWireframeFactory
        self.themePickerWireframeFactory = themePickerWireframeFactory
        self.onboardingService = onboardingService
        self.deepLinkHandler = deepLinkHandler
        self.networksService = networksService
        self.currencyStoreService = currencyStoreService
        self.walletService = walletService
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
        case let .wallet(wallet, currency):
            accountWireframeFactory.makeWireframe(
                presentingIn: vc,
                context: .init(wallet: wallet, currency: currency)
            ).present()

        case .keyStoreNetworkSettings:
            vc.edgeCardsController?.setDisplayMode(.overview, animated: true)

        case .presentUnderConstructionAlert:
            let context = AlertContext.underConstructionAlert()
            alertWireframeFactory.makeWireframe(parent, context: context).present()

        case .mnemonicConfirmation:
            mnemonicConfirmationWireframeFactory.makeWireframe(parent).present()

        case .receive:
            let source = TokenPickerWireframeContext.Source.select(
                onCompletion: { [weak self] selectedToken in
                    guard let self = self else { return }
                    self.tokenReceiveWireframeFactory.makeWireframe(
                        presentingIn: self.navigationController,
                        context: .init(presentationStyle: .push, web3Token: selectedToken)
                    ).present()
                }
            )
            
            let context = TokenPickerWireframeContext(
                presentationStyle: .push,
                title: .receive,
                selectedNetwork: nil,
                networks: .all,
                source: source,
                showAddCustomToken: true
            )
            tokenPickerWireframeFactory.makeWireframe(
                presentingIn: navigationController,
                context: context
            ).present()

        case let .send(addressTo):
            
            guard let addressTo = addressTo else {
                navigateToTokenPicker()
                return
            }

            tokenSendWireframeFactory.makeWireframe(
                presentingIn: navigationController,
                context: .init(presentationStyle: .push, addressTo: addressTo)
            ).present()
            
        case let .scanQRCode(onCompletion):
            guard let network = networksService.network else { return }
            let wireframe = qrCodeScanWireframeFactory.makeWireframe(
                presentingIn: parent,
                context: .init(
                    presentationStyle: .present,
                    type: .network(Web3Network.from(network, isOn: false)),
                    onCompletion: onCompletion
                )
            )
            wireframe.present()

        case let .nftItem(nftItem):
            nftDetailWireframeFactory.makeWireframe(
                navigationController,
                context: .init(
                    nftIdentifier: nftItem.identifier,
                    nftCollectionIdentifier: nftItem.collectionIdentifier,
                    presentationStyle: .push
                )
            ).present()
            
        case let .editTokens(network, selectedTokens, onCompletion):
            let source: TokenPickerWireframeContext.Source = .multiSelectEdit(
                selectedTokens: selectedTokens,
                onCompletion: onCompletion
            )
            let wireframe = tokenPickerWireframeFactory.makeWireframe(
                presentingIn: parent,
                context: .init(
                    presentationStyle: .present,
                    title: .multiSelectEdit,
                    selectedNetwork: nil,
                    networks: .subgroup(networks: [network]),
                    source: source,
                    showAddCustomToken: true
                )
            )
            wireframe.present()
            
        case .tokenSwap:
            let wireframe = tokenSwapWireframeFactory.makeWireframe(
                presentingIn: navigationController,
                context: .init(
                    presentationStyle: .push,
                    tokenFrom: nil,
                    tokenTo: nil
                )
            )
            wireframe.present()
            
        case let .deepLink(deepLink):
            deepLinkHandler.handle(deepLink: deepLink)
            
        case .themePicker:
            
            guard let presentingIn = navigationController.topViewController else { return }
            themePickerWireframeFactory.makeWireframe(
                presentingIn: presentingIn
            ).present()
        }
    }
}

private extension DefaultDashboardWireframe {

    func wireUp() -> UIViewController {
        let interactor = DefaultDashboardInteractor(
            networksService: networksService,
            currencyStoreService: currencyStoreService,
            walletService: walletService,
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
        let navigationController = NavigationController(rootViewController: vc)
        self.navigationController = navigationController
        return navigationController
    }
    
    func navigateToTokenPicker() {
        
        let source = TokenPickerWireframeContext.Source.select(
            onCompletion: { [weak self] selectedToken in
                guard let self = self else { return }
                self.tokenSendWireframeFactory.makeWireframe(
                    presentingIn: self.navigationController,
                    context: .init(presentationStyle: .push, web3Token: selectedToken)
                ).present()
            }
        )
        
        let context = TokenPickerWireframeContext(
            presentationStyle: .push,
            title: .send,
            selectedNetwork: nil,
            networks: .all,
            source: source,
            showAddCustomToken: true
        )
        tokenPickerWireframeFactory.makeWireframe(
            presentingIn: navigationController,
            context: context
        ).present()
    }
}
