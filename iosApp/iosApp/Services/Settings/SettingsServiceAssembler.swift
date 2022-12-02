// Created by web3d4v on 16/05/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import web3walletcore

final class SettingsServiceAssembler: AssemblerComponent {
    
    func register(to registry: AssemblerRegistry) {
        
        registry.register(scope: .singleton) { resolver -> SettingsService in
            DefaultSettingsService(
                store: KeyValueStore(name: "\(SettingsService.self)")
            )
        }
    }
}
