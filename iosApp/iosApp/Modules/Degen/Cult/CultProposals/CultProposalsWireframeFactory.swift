// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol CultProposalsWireframeFactory {

    func makeWireframe(_ parent: UIViewController) -> CultProposalsWireframe
}

final class DefaultCultProposalsWireframeFactory {

    private let cultProposalWireframeFactory: CultProposalWireframeFactory
    private let alertWireframeFactory: AlertWireframeFactory
    private let cultService: CultService

    init(
        cultProposalWireframeFactory: CultProposalWireframeFactory,
        alertWireframeFactory: AlertWireframeFactory,
        cultService: CultService
    ) {
        self.cultProposalWireframeFactory = cultProposalWireframeFactory
        self.alertWireframeFactory = alertWireframeFactory
        self.cultService = cultService
    }
}

extension DefaultCultProposalsWireframeFactory: CultProposalsWireframeFactory {

    func makeWireframe(_ parent: UIViewController) -> CultProposalsWireframe {
        
        DefaultCultProposalsWireframe(
            parent: parent,
            cultProposalWireframeFactory: cultProposalWireframeFactory,
            alertWireframeFactory: alertWireframeFactory,
            cultService: cultService
        )
    }
}
