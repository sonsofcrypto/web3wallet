// Created by web3d4v on 06/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3lib

// MARK: - TokenPickerWireframeFactory

protocol TokenPickerWireframeFactory {
    func make(
        _ parent: UIViewController?,
        context: TokenPickerWireframeContext
    ) -> TokenPickerWireframe
}

// MARK: - DefaultTokenPickerWireframeFactory

final class DefaultTokenPickerWireframeFactory {
    private let tokenAddWireframeFactory: CurrencyAddWireframeFactory
    private let walletService: WalletService
    private let networksService: NetworksService
    private let currencyStoreService: CurrencyStoreService
    
    init(
        tokenAddWireframeFactory: CurrencyAddWireframeFactory,
        walletService: WalletService,
        networksService: NetworksService,
        currencyStoreService: CurrencyStoreService
    ) {
        self.tokenAddWireframeFactory = tokenAddWireframeFactory
        self.walletService = walletService
        self.networksService = networksService
        self.currencyStoreService = currencyStoreService
    }
}

extension DefaultTokenPickerWireframeFactory: TokenPickerWireframeFactory {

    func make(
        _ parent: UIViewController?,
        context: TokenPickerWireframeContext
    ) -> TokenPickerWireframe {
        DefaultTokenPickerWireframe(
            parent,
            context: context,
            tokenAddWireframeFactory: tokenAddWireframeFactory,
            walletService: walletService,
            networksService: networksService,
            currencyStoreService: currencyStoreService
        )
    }
}

// MARK: - Assembler

final class TokenPickerWireframeFactoryAssembler: AssemblerComponent {
    
    func register(to registry: AssemblerRegistry) {
        registry.register(scope: .instance) { resolver -> TokenPickerWireframeFactory in
            DefaultTokenPickerWireframeFactory(
                tokenAddWireframeFactory: resolver.resolve(),
                walletService: resolver.resolve(),
                networksService: resolver.resolve(),
                currencyStoreService: resolver.resolve()
            )
        }
    }
}
