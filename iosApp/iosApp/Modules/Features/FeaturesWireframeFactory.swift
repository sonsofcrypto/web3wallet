// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol FeaturesWireframeFactory {

    func makeWireframe(_ parent: UIViewController) -> FeaturesWireframe
}

final class DefaultFeaturesWireframeFactory {

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

extension DefaultFeaturesWireframeFactory: FeaturesWireframeFactory {

    func makeWireframe(_ parent: UIViewController) -> FeaturesWireframe {
        
        DefaultFeaturesWireframe(
            parent: parent,
            cultProposalWireframeFactory: cultProposalWireframeFactory,
            alertWireframeFactory: alertWireframeFactory,
            cultService: cultService
        )
    }
}
