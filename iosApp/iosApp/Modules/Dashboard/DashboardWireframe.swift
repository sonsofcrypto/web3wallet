// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

enum DashboardWireframeDestination {
    case wallet(network: Network, currency: Currency)
    case keyStoreNetworkSettings
    case presentUnderConstructionAlert
    case receive
    case send(addressTo: String?)
    case scanQRCode
    case nftItem(NFTItem)
    case editCurrencies(
        network: Network,
        selectedCurrencies: [Currency],
        onCompletion: ([Currency]) -> Void
    )
    case tokenSwap
    case mnemonicConfirmation
    case themePicker
    case improvmentProposals
    case deepLink(DeepLink)

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
    private let improvementProposalsWireframeFactory: ImprovementProposalsWireframeFactory
    private let deepLinkHandler: DeepLinkHandler
    private let networksService: NetworksService
    private let currencyStoreService: CurrencyStoreService
    private let walletService: WalletService
    private let nftsService: NFTsService
    private let actionsService: ActionsService

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
        improvementProposalsWireframeFactory: ImprovementProposalsWireframeFactory,
        deepLinkHandler: DeepLinkHandler,
        networksService: NetworksService,
        currencyStoreService: CurrencyStoreService,
        walletService: WalletService,
        nftsService: NFTsService,
        actionsService: ActionsService
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
        self.improvementProposalsWireframeFactory = improvementProposalsWireframeFactory
        self.deepLinkHandler = deepLinkHandler
        self.networksService = networksService
        self.currencyStoreService = currencyStoreService
        self.walletService = walletService
        self.nftsService = nftsService
        self.actionsService = actionsService
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
            alertWireframeFactory.make(parent, context: .underConstructionAlert()).present()
        case .receive:
            let onCompletion: (([CurrencyPickerWireframeContext.Result]) -> Void) = {
                [weak self] result in
                guard let self = self else { return }
                guard
                    let network = result.first?.network,
                    let currency = result.first?.selectedCurrencies.first
                else { return }
                self.currencyReceiveWireframeFactory.make(
                    self.vc?.presentedViewController ?? self.vc,
                    context: .init(network: network, currency: currency)
                ).present()
            }
            currencyPickerWireframeFactory.make(
                vc,
                context: .init(
                    isMultiSelect: false,
                    showAddCustomCurrency: false,
                    networksData: networksService.enabledNetworks().compactMap{
                        .init(network: $0, favouriteCurrencies: nil, currencies: nil)
                    },
                    selectedNetwork: nil,
                    handler: onCompletion
                )
            ).present()
        case let .send(address):
            guard let network = networksService.network, let address = address else {
                navigateToCurrencyPickerAndSend()
                return
            }
            currencySendWireframeFactory.make(
                vc,
                context: .init(network: network, address: address, currency: nil)
            ).present()
        case .scanQRCode:
            guard let network = networksService.network else { return }
            let context = QRCodeScanWireframeContext(
                type: QRCodeScanWireframeContext.Type_Network(network: network),
                handler: navigateToCurrencySend()
            )
            qrCodeScanWireframeFactory.make(vc, context: context).present()
        case let .nftItem(nftItem):
            guard let vc = self.vc else { return }
            let context = NFTDetailWireframeContext(
                nftId: nftItem.identifier,
                collectionId: nftItem.collectionIdentifier
            )
            nftDetailWireframeFactory.make(vc, context: context).present()
        case let .editCurrencies(network, selectedCurrencies, onCompletion):
            let onCompletion: (([CurrencyPickerWireframeContext.Result]) -> Void) = { result in
                guard let currencies = result.first?.selectedCurrencies else { return }
                onCompletion(currencies)
            }
            currencyPickerWireframeFactory.make(
                vc,
                context: .init(
                    isMultiSelect: true,
                    showAddCustomCurrency: true,
                    networksData: [.init(network: network, favouriteCurrencies: selectedCurrencies, currencies: nil)],
                    selectedNetwork: nil,
                    handler: onCompletion
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
        case .mnemonicConfirmation:
            mnemonicConfirmationWireframeFactory.make(parent).present()
        case .themePicker:
            themePickerWireframeFactory.make(vc).present()
        case .improvmentProposals:
            improvementProposalsWireframeFactory.make(vc).present()
        case let .deepLink(deepLink):
            deepLinkHandler.handle(deepLink: deepLink)
        }
    }
}

private extension DefaultDashboardWireframe {

    func wireUp() -> UIViewController {
        let interactor = DefaultDashboardInteractor(
            networksService: networksService,
            currencyStoreService: currencyStoreService,
            walletService: walletService,
            nftsService: nftsService,
            actionsService: actionsService
        )
        let vc: DashboardViewController = UIStoryboard(.dashboard).instantiate()
        let presenter = DefaultDashboardPresenter(
            view: vc,
            wireframe: self,
            interactor: interactor
        )
        vc.presenter = presenter
        let nc = NavigationController(rootViewController: vc)
        self.vc = nc
        return nc
    }
    
    func navigateToCurrencyPickerAndSend() {
        guard let vc = self.vc else { return }
        let onCompletion: (([CurrencyPickerWireframeContext.Result]) -> Void) = { [weak self] result in
            guard
                let self = self,
                let network = result.first?.network,
                let currency = result.first?.selectedCurrencies.first
            else { return }
            self.currencySendWireframeFactory.make(
                vc.presentedViewController ?? vc,
                context: .init(network: network, address: nil, currency: currency)
            ).present()
        }
        currencyPickerWireframeFactory.make(
            vc,
            context: .init(
                isMultiSelect: false,
                showAddCustomCurrency: false,
                networksData: networksService.enabledNetworks().compactMap{
                    .init(network: $0, favouriteCurrencies: nil, currencies: nil)
                },
                selectedNetwork: nil,
                handler: onCompletion
            )
        ).present()
    }
    
    func navigateToCurrencySend() -> (String) -> Void {
        { [weak self] addressTo in self?.navigate(to: .send(addressTo: addressTo)) }
    }

}
