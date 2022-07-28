// Created by web3d4v on 16/05/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

final class NFTsServiceAssembler: AssemblerComponent {
    
    func register(to registry: AssemblerRegistry) {
        
        registry.register(scope: .singleton) { resolver -> NFTsService in
            
            let settingsService: SettingsService = resolver.resolve()
            
            if settingsService.isSelected(
                item: .debugAPIsNFTs,
                action: .debugAPIsNFTsMock
            ) {
                
                return DefaultNFTsService()
                
            } else if settingsService.isSelected(
                item: .debugAPIsNFTs,
                action: .debugAPIsNFTsOpenSea
            ) {
                
                return OpenSeaNFTsService(
                    web3Service: resolver.resolve()
                )
                
            } else {
                
                return DefaultNFTsService()
            }
        }
    }
}
