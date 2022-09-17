// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3lib

enum DashboardWireframeDestination {
    case wallet(network: Network, currency: Currency)
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

    private weak var parent: UIViewController?
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

    private weak var vc: UIViewController?

    init(
        _ parent: UIViewController?,
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
        let vc = wireUp()
        if let tabVc = parent as? UITabBarController {
            let vcs: [UIViewController] = [vc] + (tabVc.viewControllers ?? [])
            tabVc.setViewControllers(vcs, animated: false)
        } else {
            parent?.show(vc, sender: self)
        }
    }

    func navigate(to destination: DashboardWireframeDestination) {
        guard let vc = self.vc ?? parent else {
            print("DefaultDashboardWireframe has no view")
            return
        }
        switch destination {
        case let .wallet(network, currency):
            accountWireframeFactory.make(
                vc,
                context: .init(network: network, currency: currency)
            ).present()
        case .keyStoreNetworkSettings:
            vc.edgeCardsController?.setDisplayMode(.overview, animated: true)
        case .presentUnderConstructionAlert:
            let context = AlertContext.underConstructionAlert()
            alertWireframeFactory.make(parent, context: context).present()
        case .mnemonicConfirmation:
            mnemonicConfirmationWireframeFactory.makeWireframe(parent).present()
        case .receive:
            guard let vc = self.vc else { return }
            let source = TokenPickerWireframeContext.Source.select(
                onCompletion: { [weak self] selectedToken in
                    guard let self = self else { return }
                    let network = selectedToken.network.toNetwork()
                    let currency = selectedToken.toCurrency()
                    self.tokenReceiveWireframeFactory.make(
                        vc,
                        context: .init(network: network, currency: currency)
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
                presentingIn: vc,
                context: context
            ).present()
        case let .send(addressTo):
            guard let vc = self.vc else { return }
            guard let addressTo = addressTo else {
                navigateToTokenPicker()
                return
            }
            tokenSendWireframeFactory.makeWireframe(
                presentingIn: vc,
                context: .init(presentationStyle: .push, addressTo: addressTo)
            ).present()
        case let .scanQRCode(onCompletion):
            guard let network = networksService.network else { return }
            let wireframe = qrCodeScanWireframeFactory.make(
                vc,
                context: .init(type: .network(network), onCompletion: onCompletion)
            )
            wireframe.present()
        case let .nftItem(nftItem):
            guard let vc = self.vc else { return }
            nftDetailWireframeFactory.makeWireframe(
                vc,
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
            guard let vc = self.vc else { return }
            let wireframe = tokenSwapWireframeFactory.makeWireframe(
                presentingIn: vc,
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
            themePickerWireframeFactory.make(vc).present()
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
            wireframe: self,
            interactor: interactor,
            onboardingService: onboardingService
        )
        vc.presenter = presenter
        let nc = NavigationController(rootViewController: vc)
        self.vc = nc
        return nc
    }
    
    func navigateToTokenPicker() {
        guard let vc = self.vc else { return }
        let source = TokenPickerWireframeContext.Source.select(
            onCompletion: { [weak self] selectedToken in
                guard let self = self else { return }
                self.tokenSendWireframeFactory.makeWireframe(
                    presentingIn: vc,
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
            presentingIn: vc,
            context: context
        ).present()
    }
}
