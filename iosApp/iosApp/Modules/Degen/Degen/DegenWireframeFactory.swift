// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol DegenWireframeFactory {

    func makeWireframe(_ parent: TabBarController) -> DegenWireframe
}

final class DefaultDegenWireframeFactory {

    private let tokenSwapWireframeFactory: TokenSwapWireframeFactory
    private let cultProposalsWireframeFactory: CultProposalsWireframeFactory
    private let alertWireframeFactory: AlertWireframeFactory
    private let degenService: DegenService

    init(
        tokenSwapWireframeFactory: TokenSwapWireframeFactory,
        cultProposalsWireframeFactory: CultProposalsWireframeFactory,
        alertWireframeFactory: AlertWireframeFactory,
        degenService: DegenService
    ) {
        self.tokenSwapWireframeFactory = tokenSwapWireframeFactory
        self.cultProposalsWireframeFactory = cultProposalsWireframeFactory
        self.alertWireframeFactory = alertWireframeFactory
        self.degenService = degenService
    }
}

extension DefaultDegenWireframeFactory: DegenWireframeFactory {

    func makeWireframe(_ parent: TabBarController) -> DegenWireframe {
        
        DefaultDegenWireframe(
            parent: parent,
            tokenSwapWireframeFactory: tokenSwapWireframeFactory,
            cultProposalsWireframeFactory: cultProposalsWireframeFactory,
            alertWireframeFactory: alertWireframeFactory,
            degenService: degenService
        )
    }
}
