// Created by web3d3v on 06/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

final class CultProposalWireframeFactoryAssembler: AssemblerComponent {

    func register(to registry: AssemblerRegistry) {

        registry.register(scope: .instance) { resolver -> CultProposalWireframeFactory in

            DefaultCultProposalWireframeFactory()
        }
    }
}