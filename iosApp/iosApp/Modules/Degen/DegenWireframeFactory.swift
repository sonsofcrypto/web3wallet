// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

// MARK: - DegenWireframeFactory

protocol DegenWireframeFactory {
    func make(_ parent: TabBarController) -> DegenWireframe
}

// MARK: - DefaultDegenWireframeFactory

final class DefaultDegenWireframeFactory {
    private let currencySwapWireframeFactory: CurrencySwapWireframeFactory
    private let cultProposalsWireframeFactory: CultProposalsWireframeFactory
    private let alertWireframeFactory: AlertWireframeFactory
    private let degenService: DegenService
    private let networksService: NetworksService
    private let walletService: WalletService

    init(
        currencySwapWireframeFactory: CurrencySwapWireframeFactory,
        cultProposalsWireframeFactory: CultProposalsWireframeFactory,
        alertWireframeFactory: AlertWireframeFactory,
        degenService: DegenService,
        networksService: NetworksService,
        walletService: WalletService
    ) {
        self.currencySwapWireframeFactory = currencySwapWireframeFactory
        self.cultProposalsWireframeFactory = cultProposalsWireframeFactory
        self.alertWireframeFactory = alertWireframeFactory
        self.degenService = degenService
        self.networksService = networksService
        self.walletService = walletService
    }
}

extension DefaultDegenWireframeFactory: DegenWireframeFactory {

    func make(_ parent: TabBarController) -> DegenWireframe {
        DefaultDegenWireframe(
            parent,
            currencySwapWireframeFactory: currencySwapWireframeFactory,
            cultProposalsWireframeFactory: cultProposalsWireframeFactory,
            alertWireframeFactory: alertWireframeFactory,
            degenService: degenService,
            networksService: networksService,
            walletService: walletService
        )
    }
}

// MARK: - Assembler

final class DegenWireframeFactoryAssembler: AssemblerComponent {
    
    func register(to registry: AssemblerRegistry) {
        registry.register(scope: .instance) { resolver -> DegenWireframeFactory in
            DefaultDegenWireframeFactory(
                currencySwapWireframeFactory: resolver.resolve(),
                cultProposalsWireframeFactory: resolver.resolve(),
                alertWireframeFactory: resolver.resolve(),
                degenService: resolver.resolve(),
                networksService: resolver.resolve(),
                walletService: resolver.resolve()
            )
        }
    }
}

