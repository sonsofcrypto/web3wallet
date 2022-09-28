// Created by web3d4v on 16/05/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

final class SettingsServiceAssembler: AssemblerComponent {
    
    func register(to registry: AssemblerRegistry) {
        
        registry.register(scope: .singleton) { resolver -> SettingsService in
            let service = DefaultSettingsService(
                defaults: .standard,
                keyStoreService: resolver.resolve()
            )
            if !service.isInitialized(item: .theme) {
                service.didSelect(item: .theme, action: .themeMiamiLight, fireAction: false)
            }
            if !service.isInitialized(item: .debugAPIsNFTs) {
                service.didSelect(
                    item: .debugAPIsNFTs,
                    action: .debugAPIsNFTsOpenSea,
                    fireAction: false
                )
            }
            if !service.isInitialized(item: .debugTransitions) {
                service.didSelect(
                    item: .debugTransitions,
                    action: .debugTransitionsCardFlip,
                    fireAction: false
                )
            }
            return service
        }
    }
}
