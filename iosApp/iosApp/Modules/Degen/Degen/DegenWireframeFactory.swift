// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol DegenWireframeFactory {

    func makeWireframe(_ parent: TabBarController) -> DegenWireframe
}

final class DefaultDegenWireframeFactory {

    private let degenService: DegenService
    private let ammsWireframeFactory: AMMsWireframeFactory
    private let cultProposalsWireframeFactory: CultProposalsWireframeFactory

    init(
        degenService: DegenService,
        ammsWireframeFactory: AMMsWireframeFactory,
        cultProposalsWireframeFactory: CultProposalsWireframeFactory
    ) {
        self.degenService = degenService
        self.ammsWireframeFactory = ammsWireframeFactory
        self.cultProposalsWireframeFactory = cultProposalsWireframeFactory
    }
}

extension DefaultDegenWireframeFactory: DegenWireframeFactory {

    func makeWireframe(_ parent: TabBarController) -> DegenWireframe {
        
        DefaultDegenWireframe(
            parent: parent,
            degenService: degenService,
            ammsWireframeFactory: ammsWireframeFactory,
            cultProposalsWireframeFactory: cultProposalsWireframeFactory
        )
    }
}
