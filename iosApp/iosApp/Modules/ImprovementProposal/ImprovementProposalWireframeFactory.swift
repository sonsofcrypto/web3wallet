// Created by web3d4v on 31/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol ImprovementProposalWireframeFactory {
    func make(
        _ parent: UIViewController?,
        context: ImprovementProposalWireframeContext
    ) -> ImprovementProposalWireframe
}

final class DefaultImprovementProposalWireframeFactory: ImprovementProposalWireframeFactory {
    
    func make(
        _ parent: UIViewController?,
        context: ImprovementProposalWireframeContext
    ) -> ImprovementProposalWireframe {
        DefaultImprovementProposalWireframe(parent, context: context)
    }
}

// MARK: - Assembler

final class ProposalWireframeFactoryAssembler: AssemblerComponent {

    func register(to registry: AssemblerRegistry) {
        registry.register(scope: .instance) { resolver -> ImprovementProposalWireframeFactory in
            DefaultImprovementProposalWireframeFactory()
        }
    }
}
