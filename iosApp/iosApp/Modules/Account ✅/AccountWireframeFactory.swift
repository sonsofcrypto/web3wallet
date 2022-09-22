// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3lib

// MARK: - AccountWireframeFactory

protocol AccountWireframeFactory {
    func make(
        _ parent: UIViewController?,
        context: AccountWireframeContext
    ) -> AccountWireframe
}

// MARK: - DefaultAccountWireframeFactory

final class DefaultAccountWireframeFactory {
    private let tokenReceiveWireframeFactory: CurrencyReceiveWireframeFactory
    private let currencySendWireframeFactory: CurrencyCurrencyWireframeFactory
    private let tokenSwapWireframeFactory: TokenSwapWireframeFactory
    private let deepLinkHandler: DeepLinkHandler
    private let networksService: NetworksService
    private let currencyStoreService: CurrencyStoreService
    private let walletService: WalletService
    private let transactionService: IosEtherscanService

    init(
        tokenReceiveWireframeFactory: CurrencyReceiveWireframeFactory,
        currencySendWireframeFactory: CurrencyCurrencyWireframeFactory,
        tokenSwapWireframeFactory: TokenSwapWireframeFactory,
        deepLinkHandler: DeepLinkHandler,
        networksService: NetworksService,
        currencyStoreService: CurrencyStoreService,
        walletService: WalletService,
        transactionService: IosEtherscanService
    ) {
        self.tokenReceiveWireframeFactory = tokenReceiveWireframeFactory
        self.currencySendWireframeFactory = currencySendWireframeFactory
        self.tokenSwapWireframeFactory = tokenSwapWireframeFactory
        self.deepLinkHandler = deepLinkHandler
        self.networksService = networksService
        self.currencyStoreService = currencyStoreService
        self.walletService = walletService
        self.transactionService = transactionService
    }
}

extension DefaultAccountWireframeFactory: AccountWireframeFactory {

    func make(
        _ parent: UIViewController?,
        context: AccountWireframeContext
    ) -> AccountWireframe {
        DefaultAccountWireframe(
            parent,
            context: context,
            tokenReceiveWireframeFactory: tokenReceiveWireframeFactory,
            currencySendWireframeFactory: currencySendWireframeFactory,
            tokenSwapWireframeFactory: tokenSwapWireframeFactory,
            deepLinkHandler: deepLinkHandler,
            networksService: networksService,
            currencyStoreService: currencyStoreService,
            walletService: walletService,
            transactionService: transactionService
        )
    }
}

// MARK: - Assembler

final class AccountWireframeFactoryAssembler: AssemblerComponent {

    func register(to registry: AssemblerRegistry) {
        registry.register(scope: .instance) { resolver -> AccountWireframeFactory in
            DefaultAccountWireframeFactory(
                tokenReceiveWireframeFactory: resolver.resolve(),
                currencySendWireframeFactory: resolver.resolve(),
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
