// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

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
        self.networksService = networksService
        self.currencyStoreService = currencyStoreService
        self.walletService = walletService
        self.nftsService = nftsService
        self.actionsService = actionsService
    }
}

extension DefaultDashboardWireframe {

    func present() {
        let vc = wireUp()
        if let tabVc = parent as? UITabBarController {
            let vcs = tabVc.viewControllers ?? [] + [vc]
            tabVc.setViewControllers(vcs, animated: false)
        } else {
            parent?.show(vc, sender: self)
        }
    }

    func navigate(with destination: DashboardWireframeDestination) {
        guard let vc = self.vc ?? parent else {
            print("DefaultDashboardWireframe has no view")
            return
        }
        if destination is DashboardWireframeDestination.KeyStoreNetworkSettings {
            vc.edgeCardsController?.setDisplayMode(.overview, animated: true)
        }
        if destination is DashboardWireframeDestination.PresentUnderConstructionAlert {
            alertWireframeFactory.make(parent, context: .underConstructionAlert()).present()
        }
        if destination is DashboardWireframeDestination.ScanQRCode {
            guard let network = networksService.network else { return }
            let context = QRCodeScanWireframeContext(
                type: QRCodeScanWireframeContext.Type_Network(network: network),
                handler: navigateToCurrencySend()
            )
            qrCodeScanWireframeFactory.make(vc, context: context).present()
        }
        if destination is DashboardWireframeDestination.Receive {
            navigateToReceive()
        }
        if let input = destination as? DashboardWireframeDestination.Send {
            guard let network = networksService.network, let address = input.addressTo else {
                navigateToCurrencyPickerAndSend()
                return
            }
            currencySendWireframeFactory.make(
                vc,
                context: .init(network: network, address: address, currency: nil)
            ).present()
        }
        if destination is DashboardWireframeDestination.Swap {
            guard let network = networksService.network else { return }
            currencySwapWireframeFactory.make(
                vc,
                context: .init(network: network, currencyFrom: nil, currencyTo: nil)
            ).present()
        }
        if destination is DashboardWireframeDestination.MnemonicConfirmation {
            mnemonicConfirmationWireframeFactory.make(parent).present()
        }
        if destination is DashboardWireframeDestination.ThemePicker {
            themePickerWireframeFactory.make(vc).present()
        }
        if destination is DashboardWireframeDestination.ImprovementProposals {
            improvementProposalsWireframeFactory.make(vc).present()
        }
        if let input = destination as? DashboardWireframeDestination.EditCurrencies {
            let onCompletion: (([CurrencyPickerWireframeContext.Result]) -> Void) = { result in
                guard let currencies = result.first?.selectedCurrencies else { return }
                input.onCompletion(currencies)
            }
            currencyPickerWireframeFactory.make(
                vc,
                context: .init(
                    isMultiSelect: true,
                    showAddCustomCurrency: true,
                    networksData: [
                        .init(network: input.network, favouriteCurrencies: input.selectedCurrencies, currencies: nil)
                    ],
                    selectedNetwork: nil,
                    handler: onCompletion
                )
            ).present()
        }
        if let input = destination as? DashboardWireframeDestination.Wallet {
            accountWireframeFactory.make(
                vc,
                context: .init(network: input.network, currency: input.currency)
            ).present()
        }
        if let input = destination as? DashboardWireframeDestination.NftItem {
            guard let vc = self.vc else { return }
            let context = NFTDetailWireframeContext(
                nftId: input.nft.identifier,
                collectionId: input.nft.collectionIdentifier
            )
            nftDetailWireframeFactory.make(vc, context: context).present()
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
            view: WeakRef(referred: vc),
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
        { [weak self] addressTo in self?.navigate(with: DashboardWireframeDestination.Send(addressTo: addressTo)) }
    }

    func navigateToReceive() {
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
    }
}
