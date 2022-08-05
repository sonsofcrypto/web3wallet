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
    private let walletConnectionService: WalletsConnectionService
    private let walletsStateService: WalletsStateService
    private let currenciesService: CurrenciesService
    private let currencyMetadataService: CurrencyMetadataService

    init(
        tokenReceiveWireframeFactory: TokenReceiveWireframeFactory,
        tokenSendWireframeFactory: TokenSendWireframeFactory,
        tokenSwapWireframeFactory: TokenSwapWireframeFactory,
        deepLinkHandler: DeepLinkHandler,
        walletConnectionService: WalletsConnectionService,
        walletsStateService: WalletsStateService,
        currenciesService: CurrenciesService,
        currencyMetadataService: CurrencyMetadataService
    ) {
        self.tokenReceiveWireframeFactory = tokenReceiveWireframeFactory
        self.tokenSendWireframeFactory = tokenSendWireframeFactory
        self.tokenSwapWireframeFactory = tokenSwapWireframeFactory
        self.deepLinkHandler = deepLinkHandler
        self.walletConnectionService = walletConnectionService
        self.walletsStateService = walletsStateService
        self.currenciesService = currenciesService
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
            walletConnectionService: walletConnectionService,
            walletsStateService: walletsStateService,
            currenciesService: currenciesService,
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
                walletConnectionService: resolver.resolve(),
                walletsStateService: resolver.resolve(),
                currenciesService: resolver.resolve(),
                currencyMetadataService: resolver.resolve()
            )
        }
    }
}
