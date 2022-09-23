// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3lib

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

    init(
        currencySwapWireframeFactory: CurrencySwapWireframeFactory,
        cultProposalsWireframeFactory: CultProposalsWireframeFactory,
        alertWireframeFactory: AlertWireframeFactory,
        degenService: DegenService,
        networksService: NetworksService
    ) {
        self.currencySwapWireframeFactory = currencySwapWireframeFactory
        self.cultProposalsWireframeFactory = cultProposalsWireframeFactory
        self.alertWireframeFactory = alertWireframeFactory
        self.degenService = degenService
        self.networksService = networksService
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
            networksService: networksService
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
                networksService: resolver.resolve()
            )
        }
    }
}

