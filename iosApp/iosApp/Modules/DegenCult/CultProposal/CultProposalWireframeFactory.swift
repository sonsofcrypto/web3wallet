// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

// MARK: - CultProposalWireframeFactory

protocol CultProposalWireframeFactory {
    func make(
        _ parent: UIViewController?,
        context: CultProposalWireframeContext
    ) -> CultProposalWireframe
}

// MARK: - DefaultCultProposalWireframeFactory

final class DefaultCultProposalWireframeFactory: CultProposalWireframeFactory {

    func make(
        _ parent: UIViewController?,
        context: CultProposalWireframeContext
    ) -> CultProposalWireframe {
        DefaultCultProposalWireframe(
            parent,
            context: context
        )
    }
}

// MARK: - Assembler

final class CultProposalWireframeFactoryAssembler: AssemblerComponent {

    func register(to registry: AssemblerRegistry) {
        registry.register(scope: .instance) { resolver -> CultProposalWireframeFactory in
           DefaultCultProposalWireframeFactory()
        }
    }
}
