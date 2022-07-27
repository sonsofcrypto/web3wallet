// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

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
    private let priceHistoryService: PriceHistoryService

    init(
        tokenReceiveWireframeFactory: TokenReceiveWireframeFactory,
        tokenSendWireframeFactory: TokenSendWireframeFactory,
        tokenSwapWireframeFactory: TokenSwapWireframeFactory,
        deepLinkHandler: DeepLinkHandler,
        priceHistoryService: PriceHistoryService
    ) {
        self.tokenReceiveWireframeFactory = tokenReceiveWireframeFactory
        self.tokenSendWireframeFactory = tokenSendWireframeFactory
        self.tokenSwapWireframeFactory = tokenSwapWireframeFactory
        self.deepLinkHandler = deepLinkHandler
        self.priceHistoryService = priceHistoryService
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
            priceHistoryService: priceHistoryService
        )
    }
}
