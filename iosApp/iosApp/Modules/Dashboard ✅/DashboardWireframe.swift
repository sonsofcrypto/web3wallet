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
    case editCurrencies(
        network: Network,
        selectedCurrencies: [Currency],
        onCompletion: ([Currency]) -> Void
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
    private let currencyPickerWireframeFactory: CurrencyPickerWireframeFactory
    private let currencyReceiveWireframeFactory: CurrencyReceiveWireframeFactory
    private let currencySendWireframeFactory: CurrencyCurrencyWireframeFactory
    private let currencySwapWireframeFactory: CurrencySwapWireframeFactory
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
        currencyPickerWireframeFactory: CurrencyPickerWireframeFactory,
        currencyReceiveWireframeFactory: CurrencyReceiveWireframeFactory,
        currencySendWireframeFactory: CurrencyCurrencyWireframeFactory,
        currencySwapWireframeFactory: CurrencySwapWireframeFactory,
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
        self.currencyPickerWireframeFactory = currencyPickerWireframeFactory
        self.currencyReceiveWireframeFactory = currencyReceiveWireframeFactory
        self.currencySendWireframeFactory = currencySendWireframeFactory
        self.currencySwapWireframeFactory = currencySwapWireframeFactory
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
            let vcs = tabVc.add(viewController: vc)
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
            mnemonicConfirmationWireframeFactory.make(parent).present()
        case .receive:
            let source = CurrencyPickerWireframeContext.Source.select(
                onCompletion: { [weak self] (network, currency) in
                    guard let self = self else { return }
                    self.currencyReceiveWireframeFactory.make(
                        vc,
                        context: .init(network: network, currency: currency)
                    ).present()
                }
            )
            let context = CurrencyPickerWireframeContext(
                title: .receive,
                selectedNetwork: nil,
                networks: .all,
                source: source,
                showAddCustomCurrency: true
            )
            currencyPickerWireframeFactory.make(
                vc,
                context: context
            ).present()
        case let .send(address):
            guard let network = networksService.network, let address = address else {
                navigateToTokenPicker()
                return
            }
            currencySendWireframeFactory.make(
                vc,
                context: .init(network: network, address: address, currency: nil)
            ).present()
        case let .scanQRCode(onCompletion):
            guard let network = networksService.network else { return }
            qrCodeScanWireframeFactory.make(
                vc,
                context: .init(type: .network(network), onCompletion: onCompletion)
            ).present()
        case let .nftItem(nftItem):
            guard let vc = self.vc else { return }
            nftDetailWireframeFactory.make(
                vc,
                context: .init(
                    nftIdentifier: nftItem.identifier,
                    nftCollectionIdentifier: nftItem.collectionIdentifier
                )
            ).present()
        case let .editCurrencies(network, selectedCurrencies, onCompletion):
            let source: CurrencyPickerWireframeContext.Source = .multiSelectEdit(
                selectedCurrencies: selectedCurrencies,
                onCompletion: onCompletion
            )
            currencyPickerWireframeFactory.make(
                vc,
                context: .init(
                    title: .multiSelectEdit,
                    selectedNetwork: nil,
                    networks: .subgroup(networks: [network]),
                    source: source,
                    showAddCustomCurrency: true
                )
            ).present()
        case .tokenSwap:
            guard let network = networksService.network else { return }
            currencySwapWireframeFactory.make(
                vc,
                context: .init(
                    network: network,
                    currencyFrom: nil,
                    currencyTo: nil
                )
            ).present()
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
        let source = CurrencyPickerWireframeContext.Source.select(
            onCompletion: { [weak self] (network, currency) in
                guard let self = self else { return }
                self.currencySendWireframeFactory.make(
                    vc,
                    context: .init(network: network, address: nil, currency: currency)
                ).present()
            }
        )
        let context = CurrencyPickerWireframeContext(
            title: .send,
            selectedNetwork: nil,
            networks: .all,
            source: source,
            showAddCustomCurrency: true
        )
        currencyPickerWireframeFactory.make(
            vc,
            context: context
        ).present()
    }
}
