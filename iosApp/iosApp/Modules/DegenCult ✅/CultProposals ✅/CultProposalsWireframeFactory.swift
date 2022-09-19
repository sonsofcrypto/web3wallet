// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3lib

// MARK: - CultProposalsWireframeFactory

protocol CultProposalsWireframeFactory {

    func make(_ parent: UIViewController?) -> CultProposalsWireframe
}

// MARK: - DefaultCultProposalsWireframeFactory

final class DefaultCultProposalsWireframeFactory {

    private let cultProposalWireframeFactory: CultProposalWireframeFactory
    private let confirmationWireframeFactory: ConfirmationWireframeFactory
    private let alertWireframeFactory: AlertWireframeFactory
    private let tokenSwapWireframeFactory: TokenSwapWireframeFactory
    private let cultService: CultService
    private let walletService: WalletService

    init(
        cultProposalWireframeFactory: CultProposalWireframeFactory,
        confirmationWireframeFactory: ConfirmationWireframeFactory,
        alertWireframeFactory: AlertWireframeFactory,
        tokenSwapWireframeFactory: TokenSwapWireframeFactory,
        cultService: CultService,
        walletService: WalletService
    ) {
        self.cultProposalWireframeFactory = cultProposalWireframeFactory
        self.confirmationWireframeFactory = confirmationWireframeFactory
        self.alertWireframeFactory = alertWireframeFactory
        self.tokenSwapWireframeFactory = tokenSwapWireframeFactory
        self.cultService = cultService
        self.walletService = walletService
    }
}

extension DefaultCultProposalsWireframeFactory: CultProposalsWireframeFactory {

    func make(_ parent: UIViewController?) -> CultProposalsWireframe {
        DefaultCultProposalsWireframe(
            parent,
            cultProposalWireframeFactory: cultProposalWireframeFactory,
            confirmationWireframeFactory: confirmationWireframeFactory,
            alertWireframeFactory: alertWireframeFactory,
            tokenSwapWireframeFactory: tokenSwapWireframeFactory,
            cultService: cultService,
            walletService: walletService
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
                tokenSwapWireframeFactory: resolver.resolve(),
                cultService: resolver.resolve(),
                walletService: resolver.resolve()
            )
        }
    }
}
