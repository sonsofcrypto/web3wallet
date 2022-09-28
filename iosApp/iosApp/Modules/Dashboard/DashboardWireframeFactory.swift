// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3lib

// MARK: - DashboardWireframeFactory

protocol DashboardWireframeFactory: AnyObject {
    func make(_ parent: UIViewController?) -> DashboardWireframe
}

// MARK: - DefaultDashboardWireframeFactory

final class DefaultDashboardWireframeFactory {
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

    init(
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

extension DefaultDashboardWireframeFactory: DashboardWireframeFactory {

    func make(_ parent: UIViewController?) -> DashboardWireframe {
        DefaultDashboardWireframe(
            parent,
            accountWireframeFactory: accountWireframeFactory,
            alertWireframeFactory: alertWireframeFactory,
            mnemonicConfirmationWireframeFactory: mnemonicConfirmationWireframeFactory,
            currencyPickerWireframeFactory: currencyPickerWireframeFactory,
            currencyReceiveWireframeFactory: currencyReceiveWireframeFactory,
            currencySendWireframeFactory: currencySendWireframeFactory,
            currencySwapWireframeFactory: currencySwapWireframeFactory,
            nftDetailWireframeFactory: nftDetailWireframeFactory,
            qrCodeScanWireframeFactory: qrCodeScanWireframeFactory,
            themePickerWireframeFactory: themePickerWireframeFactory,
            onboardingService: onboardingService,
            deepLinkHandler: deepLinkHandler,
            networksService: networksService,
            currencyStoreService: currencyStoreService,
            walletService: walletService,
            nftsService: nftsService
        )
    }
}

// MARK: - Assembler

final class DashboardWireframeFactoryAssembler: AssemblerComponent {

    func register(to registry: AssemblerRegistry) {
        registry.register(scope: .instance) { resolver -> DashboardWireframeFactory in
            DefaultDashboardWireframeFactory(
                accountWireframeFactory: resolver.resolve(),
                alertWireframeFactory: resolver.resolve(),
                mnemonicConfirmationWireframeFactory: resolver.resolve(),
                currencyPickerWireframeFactory: resolver.resolve(),
                currencyReceiveWireframeFactory: resolver.resolve(),
                currencySendWireframeFactory: resolver.resolve(),
                currencySwapWireframeFactory: resolver.resolve(),
                nftDetailWireframeFactory: resolver.resolve(),
                qrCodeScanWireframeFactory: resolver.resolve(),
                themePickerWireframeFactory: resolver.resolve(),
                onboardingService: resolver.resolve(),
                deepLinkHandler: resolver.resolve(),
                networksService: resolver.resolve(),
                currencyStoreService: resolver.resolve(),
                walletService: resolver.resolve(),
                nftsService: resolver.resolve()
            )
        }
    }
}
