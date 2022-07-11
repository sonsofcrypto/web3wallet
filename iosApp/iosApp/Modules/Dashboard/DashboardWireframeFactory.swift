// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol DashboardWireframeFactory: AnyObject {
    func makeWireframe(_ parent: UIViewController) -> DashboardWireframe
}

final class DefaultDashboardWireframeFactory {

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

extension DefaultDashboardWireframeFactory: DashboardWireframeFactory {

    func makeWireframe(_ parent: UIViewController) -> DashboardWireframe {
        DefaultDashboardWireframe(
            parent: parent,
            accountWireframeFactory: accountWireframeFactory,
            alertWireframeFactory: alertWireframeFactory,
            mnemonicConfirmationWireframeFactory: mnemonicConfirmationWireframeFactory,
            tokenPickerWireframeFactory: tokenPickerWireframeFactory,
            nftDetailWireframeFactory: nftDetailWireframeFactory,
            qrCodeScanWireframeFactory: qrCodeScanWireframeFactory,
            onboardingService: onboardingService,
            web3Service: web3Service,
            priceHistoryService: priceHistoryService,
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
                nftDetailWireframeFactory: resolver.resolve(),
                qrCodeScanWireframeFactory: resolver.resolve(),
                onboardingService: resolver.resolve(),
                web3Service: resolver.resolve(),
                priceHistoryService: resolver.resolve(),
                nftsService: resolver.resolve()
            )
        }
    }
}
