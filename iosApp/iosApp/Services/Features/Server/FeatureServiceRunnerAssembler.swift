// Created by web3d4v on 17/08/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

final class FeatureServiceRunnerAssembler: AssemblerComponent {

    func register(to registry: AssemblerRegistry) {
        
        registry.register(scope: .singleton) { resolver -> FeatureServiceRunner in
            
            FeatureServiceRunner(
                featureVotingRequestService: resolver.resolve(),
                featureVotingCacheService: resolver.resolve(),
                featuresService: resolver.resolve()
            )
        }
    }
}
