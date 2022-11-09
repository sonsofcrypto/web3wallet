// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

// MARK: - CultProposalsWireframeFactory

protocol CultProposalsWireframeFactory {

    func make(_ parent: UIViewController?) -> CultProposalsWireframe
}

// MARK: - DefaultCultProposalsWireframeFactory

final class DefaultCultProposalsWireframeFactory {

    private let cultProposalWireframeFactory: CultProposalWireframeFactory
    private let confirmationWireframeFactory: ConfirmationWireframeFactory
    private let alertWireframeFactory: AlertWireframeFactory
    private let currencySwapWireframeFactory: CurrencySwapWireframeFactory
    private let cultService: CultService
    private let walletService: WalletService
    private let networksService: NetworksService

    init(
        cultProposalWireframeFactory: CultProposalWireframeFactory,
        confirmationWireframeFactory: ConfirmationWireframeFactory,
        alertWireframeFactory: AlertWireframeFactory,
        currencySwapWireframeFactory: CurrencySwapWireframeFactory,
        cultService: CultService,
        walletService: WalletService,
        networksService: NetworksService
    ) {
        self.cultProposalWireframeFactory = cultProposalWireframeFactory
        self.confirmationWireframeFactory = confirmationWireframeFactory
        self.alertWireframeFactory = alertWireframeFactory
        self.currencySwapWireframeFactory = currencySwapWireframeFactory
        self.cultService = cultService
        self.walletService = walletService
        self.networksService = networksService
    }
}

extension DefaultCultProposalsWireframeFactory: CultProposalsWireframeFactory {

    func make(_ parent: UIViewController?) -> CultProposalsWireframe {
        DefaultCultProposalsWireframe(
            parent,
            cultProposalWireframeFactory: cultProposalWireframeFactory,
            confirmationWireframeFactory: confirmationWireframeFactory,
            alertWireframeFactory: alertWireframeFactory,
            currencySwapWireframeFactory: currencySwapWireframeFactory,
            cultService: cultService,
            walletService: walletService,
            networksService: networksService
        )
    }
}

// MARK: - Assembler

final class CultProposalsWireframeFactoryAssembler: AssemblerComponent {

    func register(to registry: AssemblerRegistry) {
        registry.register(scope: .instance) { resolver -> CultProposalsWireframeFactory in
            DefaultCultProposalsWireframeFactory(
                cultProposalWireframeFactory: resolver.resolve(),
                confirmationWireframeFactory: resolver.resolve(),
                alertWireframeFactory: resolver.resolve(),
                currencySwapWireframeFactory: resolver.resolve(),
                cultService: resolver.resolve(),
                walletService: resolver.resolve(),
                networksService: resolver.resolve()
            )
        }
    }
}
