// Created by web3d4v on 14/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3lib

protocol TokenSwapWireframeFactory {
    func make(
        _ parent: UIViewController?,
        context: TokenSwapWireframeContext
    ) -> TokenSwapWireframe
}

final class DefaultTokenSwapWireframeFactory {
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

extension DefaultTokenSwapWireframeFactory: TokenSwapWireframeFactory {

    func make(
        _ parent: UIViewController?,
        context: TokenSwapWireframeContext
    ) -> TokenSwapWireframe {
        
        DefaultTokenSwapWireframe(
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

final class TokenSwapWireframeFactoryAssembler: AssemblerComponent {
    
    func register(to registry: AssemblerRegistry) {
        registry.register(scope: .instance) { resolver -> TokenSwapWireframeFactory in
            DefaultTokenSwapWireframeFactory(
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
