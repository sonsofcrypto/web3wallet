// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3lib

protocol DashboardWireframeFactory: AnyObject {
    func makeWireframe(_ parent: UIViewController) -> DashboardWireframe
}

final class DefaultDashboardWireframeFactory {

    private let accountWireframeFactory: AccountWireframeFactory
    private let alertWireframeFactory: AlertWireframeFactory
    private let mnemonicConfirmationWireframeFactory: MnemonicConfirmationWireframeFactory
    private let tokenPickerWireframeFactory: TokenPickerWireframeFactory
    private let tokenReceiveWireframeFactory: TokenReceiveWireframeFactory
    private let tokenSendWireframeFactory: TokenSendWireframeFactory
    private let tokenSwapWireframeFactory: TokenSwapWireframeFactory
    private let nftDetailWireframeFactory: NFTDetailWireframeFactory
    private let qrCodeScanWireframeFactory: QRCodeScanWireframeFactory
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
        tokenPickerWireframeFactory: TokenPickerWireframeFactory,
        tokenReceiveWireframeFactory: TokenReceiveWireframeFactory,
        tokenSendWireframeFactory: TokenSendWireframeFactory,
        tokenSwapWireframeFactory: TokenSwapWireframeFactory,
        nftDetailWireframeFactory: NFTDetailWireframeFactory,
        qrCodeScanWireframeFactory: QRCodeScanWireframeFactory,
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
        self.tokenPickerWireframeFactory = tokenPickerWireframeFactory
        self.tokenReceiveWireframeFactory = tokenReceiveWireframeFactory
        self.tokenSendWireframeFactory = tokenSendWireframeFactory
        self.tokenSwapWireframeFactory = tokenSwapWireframeFactory
        self.nftDetailWireframeFactory = nftDetailWireframeFactory
        self.qrCodeScanWireframeFactory = qrCodeScanWireframeFactory
        self.onboardingService = onboardingService
        self.deepLinkHandler = deepLinkHandler
        self.networksService = networksService
        self.currencyService = currencyService
        self.walletService = walletService
        self.nftsService = nftsService
    }
}

extension DefaultDashboardWireframeFactory: DashboardWireframeFactory {

    func makeWireframe(_ parent: UIViewController) -> DashboardWireframe {
        
        DefaultDashboardWireframe(
            parent: parent,
            accountWireframeFactory: accountWireframeFactory,
            alertWireframeFactory: alertWireframeFactory,
            mnemonicConfirmationWireframeFactory: mnemonicConfirmationWireframeFactory,
            tokenPickerWireframeFactory: tokenPickerWireframeFactory,
            tokenReceiveWireframeFactory: tokenReceiveWireframeFactory,
            tokenSendWireframeFactory: tokenSendWireframeFactory,
            tokenSwapWireframeFactory: tokenSwapWireframeFactory,
            nftDetailWireframeFactory: nftDetailWireframeFactory,
            qrCodeScanWireframeFactory: qrCodeScanWireframeFactory,
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
                tokenPickerWireframeFactory: resolver.resolve(),
                tokenReceiveWireframeFactory: resolver.resolve(),
                tokenSendWireframeFactory: resolver.resolve(),
                tokenSwapWireframeFactory: resolver.resolve(),
                nftDetailWireframeFactory: resolver.resolve(),
                qrCodeScanWireframeFactory: resolver.resolve(),
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
