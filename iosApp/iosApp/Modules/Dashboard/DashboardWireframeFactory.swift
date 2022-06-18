// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol DashboardWireframeFactory: AnyObject {

    func makeWireframe(_ parent: UIViewController) -> DashboardWireframe
}

final class DefaultDashboardWireframeFactory {

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

extension DefaultDashboardWireframeFactory: DashboardWireframeFactory {

    func makeWireframe(_ parent: UIViewController) -> DashboardWireframe {
        
        DefaultDashboardWireframe(
            parent: parent,
            keyStoreService: keyStoreService,
            accountWireframeFactory: accountWireframeFactory,
            alertWireframeFactory: alertWireframeFactory,
            mnemonicConfirmationWireframeFactory: mnemonicConfirmationWireframeFactory,
            tokenPickerWireframeFactory: tokenPickerWireframeFactory,
            nftDetailWireframeFactory: nftDetailWireframeFactory,
            onboardingService: onboardingService,
            web3Service: web3Service,
            priceHistoryService: priceHistoryService,
            nftsService: nftsService
        )
    }
}
