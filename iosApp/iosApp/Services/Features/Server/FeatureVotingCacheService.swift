// Created by web3d4v on 17/08/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

protocol FeatureVotingCacheService {
    var cachedMetadata: [String: FeatureVotingCacheMeta] { get }
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
    
    private let DEFAULTS_KEY_NAME = "features_metadata_dict"
    private (set) var cachedMetadata: [String: FeatureVotingCacheMeta] = [:]
    
    init(
        defaults: UserDefaults
    ) {
        
        self.defaults = defaults
        self.cachedMetadata = loadCachedMetadata() ?? [:]
    }
}

extension DefaultFeatureVotingCacheService: FeatureVotingCacheService {
    
    func store(metadata: FeatureVotingCacheMeta) {
        cachedMetadata[metadata.hashTag] = metadata
        cacheMetadataInUserDetauls(metadata: cachedMetadata)
    }
    
    func metadata(for feature: Web3FeatureData) -> FeatureVotingCacheMeta? {
        cachedMetadata[feature.hashTag]
    }
}

private extension DefaultFeatureVotingCacheService {
    
    func loadCachedMetadata() -> [String: FeatureVotingCacheMeta]? {
        guard let data = defaults.data(
            forKey: DEFAULTS_KEY_NAME
        ) else { return loadMetadataFromProject() }
        return try? JSONDecoder().decode([String: FeatureVotingCacheMeta].self, from: data)
    }
    
    func loadMetadataFromProject() -> [String: FeatureVotingCacheMeta]? {
        guard let path = Bundle.main.path(
            forResource: "features-metadata-dict",
            ofType: "json"
        ) else { return nil }
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe) else {
            return nil
        }
        guard let metadata = try? JSONDecoder().decode([String: FeatureVotingCacheMeta].self, from: data) else {
            return nil
        }
        cacheMetadataInUserDetauls(metadata: metadata)
        return metadata
    }
    
    func cacheMetadataInUserDetauls(
        metadata: [String: FeatureVotingCacheMeta]
    ) {
        let jsonData = try? JSONEncoder().encode(metadata)
        defaults.setValue(jsonData, forKey: DEFAULTS_KEY_NAME)
        defaults.synchronize()
    }
}
