// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3lib

protocol CultProposalsWireframeFactory {

    func makeWireframe(_ parent: UIViewController) -> CultProposalsWireframe
}

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

    func makeWireframe(_ parent: UIViewController) -> CultProposalsWireframe {
        
        DefaultCultProposalsWireframe(
            parent: parent,
            cultProposalWireframeFactory: cultProposalWireframeFactory,
            confirmationWireframeFactory: confirmationWireframeFactory,
            alertWireframeFactory: alertWireframeFactory,
            tokenSwapWireframeFactory: tokenSwapWireframeFactory,
            cultService: cultService,
            walletService: walletService
        )
    }
}
