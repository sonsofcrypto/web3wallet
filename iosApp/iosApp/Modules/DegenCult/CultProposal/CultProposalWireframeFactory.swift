// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

protocol CultProposalWireframeFactory {
    func make(
        _ parent: UIViewController?,
        context: CultProposalWireframeContext
    ) -> CultProposalWireframe
}

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

final class CultProposalWireframeFactoryAssembler: AssemblerComponent {

    func register(to registry: AssemblerRegistry) {
        registry.register(scope: .instance) { resolver -> CultProposalWireframeFactory in
           DefaultCultProposalWireframeFactory()
        }
    }
}
