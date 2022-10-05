// Created by web3d3v on 30/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

protocol ImprovementProposalsWireframeFactory {
    func make(_ parent: UIViewController?) -> ImprovementProposalsWireframe
}

final class DefaultImprovementProposalsWireframeFactory {
    private let improvementProposalWireframeFactory: ImprovementProposalWireframeFactory
    private let alertWireframeFactory: AlertWireframeFactory
    private let improvementProposalsService: ImprovementProposalsService

    init(
        improvementProposalWireframeFactory: ImprovementProposalWireframeFactory,
        alertWireframeFactory: AlertWireframeFactory,
        improvementProposalsService: ImprovementProposalsService
    ) {
        self.improvementProposalWireframeFactory = improvementProposalWireframeFactory
        self.alertWireframeFactory = alertWireframeFactory
        self.improvementProposalsService = improvementProposalsService
    }
}

extension DefaultImprovementProposalsWireframeFactory: ImprovementProposalsWireframeFactory {

    func make(_ parent: UIViewController?) -> ImprovementProposalsWireframe {
        DefaultImprovementProposalsWireframe(
            parent,
            improvementProposalWireframeFactory: improvementProposalWireframeFactory,
            alertWireframeFactory: alertWireframeFactory,
            improvementProposalsService: improvementProposalsService
        )
    }
}

final class ProposalsWireframeFactoryAssembler: AssemblerComponent {

    func register(to registry: AssemblerRegistry) {
        registry.register(scope: .instance) { resolver -> ImprovementProposalsWireframeFactory in
            DefaultImprovementProposalsWireframeFactory(
                improvementProposalWireframeFactory: resolver.resolve(),
                alertWireframeFactory: resolver.resolve(),
                improvementProposalsService: resolver.resolve()
            )
        }
    }
}
