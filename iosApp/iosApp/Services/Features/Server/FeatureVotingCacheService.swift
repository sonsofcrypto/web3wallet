// Created by web3d4v on 17/08/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

protocol FeatureVotingCacheService {
    
    func store(metadata: FeatureVotingCacheMeta)
    func metadata(for feature: Web3FeatureData) -> FeatureVotingCacheMeta?
}

struct FeatureVotingCacheMeta: Codable {
    
    let hashTag: String
    let votes: Int
    let latestId: String
}

final class DefaultFeatureVotingCacheService {
    
    let defaults: UserDefaults
    
    init(
        defaults: UserDefaults
    ) {
        
        self.defaults = defaults
    }
}

extension DefaultFeatureVotingCacheService: FeatureVotingCacheService {
    
    func store(metadata: FeatureVotingCacheMeta) {
        
        let data = try? JSONEncoder().encode(metadata)
        defaults.setValue(data, forKey: metadata.hashTag)
        defaults.synchronize()
    }
    
    func metadata(for feature: Web3FeatureData) -> FeatureVotingCacheMeta? {
        
        guard let data = defaults.data(forKey: feature.hashTag) else { return nil }
        return try? JSONDecoder().decode(FeatureVotingCacheMeta.self, from: data)
    }
}
