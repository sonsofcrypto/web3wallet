// Created by web3d3v on 04/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3walletcore

final class ActionsServiceAssembler: AssemblerComponent {

    func register(to registry: AssemblerRegistry) {

        registry.register(scope: .singleton) { resolver -> ActionsService in
            DefaultActionsService(
                store: KeyValueStore(name: "\(ActionsService.self)"),
                networksService: resolver.resolve()
            )
        }
    }
}
