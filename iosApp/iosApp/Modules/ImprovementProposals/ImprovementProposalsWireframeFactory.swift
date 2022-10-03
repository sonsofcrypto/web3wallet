// Created by web3d3v on 30/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol ImprovementProposalsWireframeFactory {
    func make(_ parent: UIViewController?) -> ImprovementProposalsWireframe
}

final class DefaultImprovementProposalsWireframeFactory {
    private let featureWireframeFactory: ImprovementProposalWireframeFactory
    private let alertWireframeFactory: AlertWireframeFactory
    private let improvementProposalsService: ImprovementProposalsService

    init(
        featureWireframeFactory: ImprovementProposalWireframeFactory,
        alertWireframeFactory: AlertWireframeFactory,
        improvementProposalsService: ImprovementProposalsService
    ) {
        self.featureWireframeFactory = featureWireframeFactory
        self.alertWireframeFactory = alertWireframeFactory
        self.improvementProposalsService = improvementProposalsService
    }
}

extension DefaultImprovementProposalsWireframeFactory: ImprovementProposalsWireframeFactory {

    func make(_ parent: UIViewController?) -> ImprovementProposalsWireframe {
        DefaultImprovementProposalsWireframe(
            parent,
            featureWireframeFactory: featureWireframeFactory,
            alertWireframeFactory: alertWireframeFactory,
            improvementProposalsService: improvementProposalsService
        )
    }
}

final class ProposalsWireframeFactoryAssembler: AssemblerComponent {

    func register(to registry: AssemblerRegistry) {
        registry.register(scope: .instance) { resolver -> ImprovementProposalsWireframeFactory in
            DefaultImprovementProposalsWireframeFactory(
                featureWireframeFactory: resolver.resolve(),
                alertWireframeFactory: resolver.resolve(),
                improvementProposalsService: resolver.resolve()
            )
        }
    }
}
