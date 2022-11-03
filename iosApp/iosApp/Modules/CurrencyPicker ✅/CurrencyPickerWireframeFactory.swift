// Created by web3d4v on 06/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

// MARK: - CurrencyPickerWireframeFactory

protocol CurrencyPickerWireframeFactory {
    func make(
        _ parent: UIViewController?,
        context: CurrencyPickerWireframeContext
    ) -> CurrencyPickerWireframe
}

// MARK: - DefaultCurrencyPickerWireframeFactory

final class DefaultCurrencyPickerWireframeFactory {
    private let currencyAddWireframeFactory: CurrencyAddWireframeFactory
    private let walletService: WalletService
    private let networksService: NetworksService
    private let currencyStoreService: CurrencyStoreService
    
    init(
        currencyAddWireframeFactory: CurrencyAddWireframeFactory,
        walletService: WalletService,
        networksService: NetworksService,
        currencyStoreService: CurrencyStoreService
    ) {
        self.currencyAddWireframeFactory = currencyAddWireframeFactory
        self.walletService = walletService
        self.networksService = networksService
        self.currencyStoreService = currencyStoreService
    }
}

extension DefaultCurrencyPickerWireframeFactory: CurrencyPickerWireframeFactory {

    func make(
        _ parent: UIViewController?,
        context: CurrencyPickerWireframeContext
    ) -> CurrencyPickerWireframe {
        DefaultCurrencyPickerWireframe(
            parent,
            context: context,
            currencyAddWireframeFactory: currencyAddWireframeFactory,
            walletService: walletService,
            networksService: networksService,
            currencyStoreService: currencyStoreService
        )
    }
}

// MARK: - Assembler

final class CurrencyPickerWireframeFactoryAssembler: AssemblerComponent {
    
    func register(to registry: AssemblerRegistry) {
        registry.register(scope: .instance) { resolver -> CurrencyPickerWireframeFactory in
            DefaultCurrencyPickerWireframeFactory(
                currencyAddWireframeFactory: resolver.resolve(),
                walletService: resolver.resolve(),
                networksService: resolver.resolve(),
                currencyStoreService: resolver.resolve()
            )
        }
    }
}
