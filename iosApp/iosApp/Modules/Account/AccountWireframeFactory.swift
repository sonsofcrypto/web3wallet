// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3lib

protocol AccountWireframeFactory {

    func makeWireframe(
        presentingIn: UIViewController,
        context: AccountWireframeContext
    ) -> AccountWireframe
}

final class DefaultAccountWireframeFactory {
    private let tokenReceiveWireframeFactory: TokenReceiveWireframeFactory
    private let tokenSendWireframeFactory: TokenSendWireframeFactory
    private let tokenSwapWireframeFactory: TokenSwapWireframeFactory
    private let deepLinkHandler: DeepLinkHandler
    private let networksService: NetworksService
    private let currencyStoreService: CurrencyStoreService
    private let walletService: WalletService
    private let transactionService: IosEtherscanService

    init(
        tokenReceiveWireframeFactory: TokenReceiveWireframeFactory,
        tokenSendWireframeFactory: TokenSendWireframeFactory,
        tokenSwapWireframeFactory: TokenSwapWireframeFactory,
        deepLinkHandler: DeepLinkHandler,
        networksService: NetworksService,
        currencyStoreService: CurrencyStoreService,
        walletService: WalletService,
        transactionService: IosEtherscanService
    ) {
        self.tokenReceiveWireframeFactory = tokenReceiveWireframeFactory
        self.tokenSendWireframeFactory = tokenSendWireframeFactory
        self.tokenSwapWireframeFactory = tokenSwapWireframeFactory
        self.deepLinkHandler = deepLinkHandler
        self.networksService = networksService
        self.currencyStoreService = currencyStoreService
        self.walletService = walletService
        self.transactionService = transactionService
    }
}

extension DefaultAccountWireframeFactory: AccountWireframeFactory {

    func makeWireframe(
        presentingIn: UIViewController,
        context: AccountWireframeContext
    ) -> AccountWireframe {
        DefaultAccountWireframe(
            presentingIn: presentingIn,
            context: context,
            tokenReceiveWireframeFactory: tokenReceiveWireframeFactory,
            tokenSendWireframeFactory: tokenSendWireframeFactory,
            tokenSwapWireframeFactory: tokenSwapWireframeFactory,
            deepLinkHandler: deepLinkHandler,
            networksService: networksService,
            currencyStoreService: currencyStoreService,
            walletService: walletService,
            transactionService: transactionService
        )
    }
}


final class AccountWireframeFactoryAssembler: AssemblerComponent {

    func register(to registry: AssemblerRegistry) {
        registry.register(scope: .instance) { resolver -> AccountWireframeFactory in
            DefaultAccountWireframeFactory(
                tokenReceiveWireframeFactory: resolver.resolve(),
                tokenSendWireframeFactory: resolver.resolve(),
                tokenSwapWireframeFactory: resolver.resolve(),
                deepLinkHandler: resolver.resolve(),
                networksService: resolver.resolve(),
                currencyStoreService: resolver.resolve(),
                walletService: resolver.resolve(),
                transactionService: resolver.resolve()
            )
        }
    }
}
