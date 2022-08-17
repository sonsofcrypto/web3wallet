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
    private let walletService: WalletService
    private let currencyStoreService: CurrencyStoreService
    private let currencyMetadataService: CurrencyMetadataService

    init(
        tokenReceiveWireframeFactory: TokenReceiveWireframeFactory,
        tokenSendWireframeFactory: TokenSendWireframeFactory,
        tokenSwapWireframeFactory: TokenSwapWireframeFactory,
        deepLinkHandler: DeepLinkHandler,
        networksService: NetworksService,
        walletService: WalletService,
        currencyStoreService: CurrencyStoreService,
        currencyMetadataService: CurrencyMetadataService
    ) {
        self.tokenReceiveWireframeFactory = tokenReceiveWireframeFactory
        self.tokenSendWireframeFactory = tokenSendWireframeFactory
        self.tokenSwapWireframeFactory = tokenSwapWireframeFactory
        self.deepLinkHandler = deepLinkHandler
        self.networksService = networksService
        self.walletService = walletService
        self.currencyService = currencyService
        self.currencyMetadataService = currencyMetadataService
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
            walletService: walletService,
            currencyStoreService: currencyStoreService,
            currencyMetadataService: currencyMetadataService
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
                walletsStateService: resolver.resolve(),
                currenciesService: resolver.resolve(),
                currencyMetadataService: resolver.resolve()
            )
        }
    }
}
