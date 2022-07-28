// Created by web3d3v on 04/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

final class FeaturesWireframeFactoryAssembler: AssemblerComponent {

    func register(to registry: AssemblerRegistry) {

        registry.register(scope: .instance) { resolver -> FeaturesWireframeFactory in

            DefaultFeaturesWireframeFactory(
                cultProposalWireframeFactory: resolver.resolve(),
                alertWireframeFactory: resolver.resolve(),
                cultService: resolver.resolve()
            )
        }
    }
}