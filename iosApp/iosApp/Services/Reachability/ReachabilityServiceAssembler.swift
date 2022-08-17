// Created by web3d4v on 16/05/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

final class ReachabilityServiceAssembler: AssemblerComponent {
    func register(to registry: AssemblerRegistry) {
        registry.register(scope: .singleton) { resolver -> ReachabilityService in
            DefaultReachabilityService()
        }
    }
}
