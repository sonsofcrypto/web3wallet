// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol AccountWireframeFactory {

    func makeWireframe(
        _ parent: UIViewController,
        wallet: KeyStoreItem,
        token: Web3Token
    ) -> AccountWireframe
}

final class DefaultAccountWireframeFactory {

    private let priceHistoryService: PriceHistoryService

    init(
        priceHistoryService: PriceHistoryService
    ) {
        self.priceHistoryService = priceHistoryService
    }
}

extension DefaultAccountWireframeFactory: AccountWireframeFactory {

    func makeWireframe(
        _ parent: UIViewController,
        wallet: KeyStoreItem,
        token: Web3Token
    ) -> AccountWireframe {
        
        DefaultAccountWireframe(
            parent: parent,
            interactor: DefaultAccountInteractor(
                priceHistoryService: priceHistoryService,
                wallet: wallet,
                token: token
            )
        )
    }
}
