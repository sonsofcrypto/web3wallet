// Created by web3d4v on 27/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

protocol FeaturesService {
    
    func fetchAllFeatures(onCompletion: @escaping (Result<[Web3Feature], Error>) -> Void)
}

final class DefaultFeaturesService {
    
    let featureVotingCacheService: FeatureVotingCacheService
    
    init(
        featureVotingCacheService: FeatureVotingCacheService
    ) {
        
        self.featureVotingCacheService = featureVotingCacheService
    }
}

extension DefaultFeaturesService: FeaturesService {
    
    func fetchAllFeatures(onCompletion: @escaping (Result<[Web3Feature], Error>) -> Void) {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            
            guard let self = self else { return }
            onCompletion(.success(self.allFeatures))
        }
    }
}

private extension DefaultFeaturesService {
    
    var allFeatures: [Web3Feature] {
        
        Web3FeatureData.allFeatures.compactMap {
            .init(
                id: $0.id,
                title: $0.title,
                body: $0.body,
                image: $0.image,
                category: $0.category,
                creationDate: $0.creationDate,
                votes: featureVotingCacheService.metadata(for: $0)?.votes ?? 0
            )
        }
    }
}
