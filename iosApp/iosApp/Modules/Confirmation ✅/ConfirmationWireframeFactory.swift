// Created by web3d4v on 20/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

// MARK: - ConfirmationWireframeFactory

protocol ConfirmationWireframeFactory {
    func make(
        _ parent: UIViewController?,
        context: ConfirmationWireframeContext
    ) -> ConfirmationWireframe
}

// MARK: - DefaultConfirmationWireframeFactory

final class DefaultConfirmationWireframeFactory {
    private let walletService: WalletService
    private let authenticateWireframeFactory: AuthenticateWireframeFactory
    private let alertWireframeFactory: AlertWireframeFactory
    private let webViewWireframeFactory: WebViewWireframeFactory
    private let deepLinkHandler: DeepLinkHandler
    private let nftsService: NFTsService
    private let mailService: MailService
    private let currencyStoreService: CurrencyStoreService

    init(
        walletService: WalletService,
        authenticateWireframeFactory: AuthenticateWireframeFactory,
        alertWireframeFactory: AlertWireframeFactory,
        webViewWireframeFactory: WebViewWireframeFactory,
        deepLinkHandler: DeepLinkHandler,
        nftsService: NFTsService,
        mailService: MailService,
        currencyStoreService: CurrencyStoreService
    ) {
        self.walletService = walletService
        self.authenticateWireframeFactory = authenticateWireframeFactory
        self.alertWireframeFactory = alertWireframeFactory
        self.webViewWireframeFactory = webViewWireframeFactory
        self.deepLinkHandler = deepLinkHandler
        self.nftsService = nftsService
        self.mailService = mailService
        self.currencyStoreService = currencyStoreService
    }
}

extension DefaultConfirmationWireframeFactory: ConfirmationWireframeFactory {

    func make(
        _ parent: UIViewController?,
        context: ConfirmationWireframeContext
    ) -> ConfirmationWireframe {
        DefaultConfirmationWireframe(
            parent,
            context: context,
            walletService: walletService,
            authenticateWireframeFactory: authenticateWireframeFactory,
            alertWireframeFactory: alertWireframeFactory,
            webViewWireframeFactory: webViewWireframeFactory,
            deepLinkHandler: deepLinkHandler,
            nftsService: nftsService,
            mailService: mailService,
            currencyStoreService: currencyStoreService
        )
    }
}

// MARK: - Assembler

final class ConfirmationWireframeFactoryAssembler: AssemblerComponent {

    func register(to registry: AssemblerRegistry) {
        registry.register(scope: .instance) { resolver -> ConfirmationWireframeFactory in
            DefaultConfirmationWireframeFactory(
                walletService: resolver.resolve(),
                authenticateWireframeFactory: resolver.resolve(),
                alertWireframeFactory: resolver.resolve(),
                webViewWireframeFactory: resolver.resolve(),
                deepLinkHandler: resolver.resolve(),
                nftsService: resolver.resolve(),
                mailService: resolver.resolve(),
                currencyStoreService: resolver.resolve()
            )
        }
    }
}
