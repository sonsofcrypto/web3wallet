// Created by web3d4v on 27/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

final class FeaturesServiceAssembler: AssemblerComponent {
    
    func register(to registry: AssemblerRegistry) {
        
        registry.register(scope: .instance) { resolver -> FeaturesService in
            
            DefaultFeaturesService(
                featureVotingCacheService: resolver.resolve(),
                defaults: .standard
            )
        }
    }
}
