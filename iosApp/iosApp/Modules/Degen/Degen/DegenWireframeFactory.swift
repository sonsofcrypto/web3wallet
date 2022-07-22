// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol DegenWireframeFactory {

    func makeWireframe(_ parent: TabBarController) -> DegenWireframe
}

final class DefaultDegenWireframeFactory {

    private let cultProposalsWireframeFactory: CultProposalsWireframeFactory
    private let degenService: DegenService

    init(
        cultProposalsWireframeFactory: CultProposalsWireframeFactory,
        degenService: DegenService
    ) {
        self.cultProposalsWireframeFactory = cultProposalsWireframeFactory
        self.degenService = degenService
    }
}

extension DefaultDegenWireframeFactory: DegenWireframeFactory {

    func makeWireframe(_ parent: TabBarController) -> DegenWireframe {
        
        DefaultDegenWireframe(
            parent: parent,
            cultProposalsWireframeFactory: cultProposalsWireframeFactory,
            degenService: degenService
        )
    }
}
