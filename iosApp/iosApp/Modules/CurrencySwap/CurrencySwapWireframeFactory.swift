// Created by web3d4v on 14/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

protocol CurrencySwapWireframeFactory {
    func make(
        _ parent: UIViewController?,
        context: CurrencySwapWireframeContext
    ) -> CurrencySwapWireframe
}

final class DefaultCurrencySwapWireframeFactory {
    private let currencyPickerWireframeFactory: CurrencyPickerWireframeFactory
    private let confirmationWireframeFactory: ConfirmationWireframeFactory
    private let alertWireframeFactory: AlertWireframeFactory
    private let walletService: WalletService
    private let networksService: NetworksService
    private let swapService: UniswapService

    init(
        currencyPickerWireframeFactory: CurrencyPickerWireframeFactory,
        confirmationWireframeFactory: ConfirmationWireframeFactory,
        alertWireframeFactory: AlertWireframeFactory,
        walletService: WalletService,
        networksService: NetworksService,
        swapService: UniswapService
    ) {
        self.currencyPickerWireframeFactory = currencyPickerWireframeFactory
        self.confirmationWireframeFactory = confirmationWireframeFactory
        self.alertWireframeFactory = alertWireframeFactory
        self.walletService = walletService
        self.networksService = networksService
        self.swapService = swapService
    }
}

extension DefaultCurrencySwapWireframeFactory: CurrencySwapWireframeFactory {

    func make(
        _ parent: UIViewController?,
        context: CurrencySwapWireframeContext
    ) -> CurrencySwapWireframe {
        
        DefaultCurrencySwapWireframe(
            parent,
            context: context,
            currencyPickerWireframeFactory: currencyPickerWireframeFactory,
            confirmationWireframeFactory: confirmationWireframeFactory,
            alertWireframeFactory: alertWireframeFactory,
            walletService: walletService,
            networksService: networksService,
            swapService: swapService
        )
    }
}

// MARK: - Assembler

final class CurrencySwapWireframeFactoryAssembler: AssemblerComponent {
    
    func register(to registry: AssemblerRegistry) {
        registry.register(scope: .instance) { resolver -> CurrencySwapWireframeFactory in
            DefaultCurrencySwapWireframeFactory(
                currencyPickerWireframeFactory: resolver.resolve(),
                confirmationWireframeFactory: resolver.resolve(),
                alertWireframeFactory: resolver.resolve(),
                walletService: resolver.resolve(),
                networksService: resolver.resolve(),
                swapService: resolver.resolve()
            )
        }
    }
}
