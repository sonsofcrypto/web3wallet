// Created by web3d3v on 30/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol ProposalsWireframeFactory {
    func make(_ parent: UIViewController?) -> ProposalsWireframe
}

final class DefaultProposalsWireframeFactory {
    private let featureWireframeFactory: FeatureWireframeFactory
    private let alertWireframeFactory: AlertWireframeFactory
    private let improvementProposalsService: ImprovementProposalsService

    init(
        featureWireframeFactory: FeatureWireframeFactory,
        alertWireframeFactory: AlertWireframeFactory,
        improvementProposalsService: ImprovementProposalsService
    ) {
        self.featureWireframeFactory = featureWireframeFactory
        self.alertWireframeFactory = alertWireframeFactory
        self.improvementProposalsService = improvementProposalsService
    }
}

extension DefaultProposalsWireframeFactory: ProposalsWireframeFactory {

    func make(_ parent: UIViewController?) -> ProposalsWireframe {
        DefaultProposalsWireframe(
            parent,
            featureWireframeFactory: featureWireframeFactory,
            alertWireframeFactory: alertWireframeFactory,
            improvementProposalsService: improvementProposalsService
        )
    }
}

final class ProposalsWireframeFactoryAssembler: AssemblerComponent {

    func register(to registry: AssemblerRegistry) {
        registry.register(scope: .instance) { resolver -> ProposalsWireframeFactory in
            DefaultProposalsWireframeFactory(
                featureWireframeFactory: resolver.resolve(),
                alertWireframeFactory: resolver.resolve(),
                improvementProposalsService: resolver.resolve()
            )
        }
    }
}
