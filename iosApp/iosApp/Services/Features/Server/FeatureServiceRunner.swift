// Created by web3d4v on 17/08/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

final class FeatureServiceRunner {
        
    let featureVotingRequestService: FeatureVotingRequestService
    let featureVotingCacheService: FeatureVotingCacheService
    let featuresService: FeaturesService
    
    private var featuresToUpdate = [Web3FeatureData]()
    
    init(
        featureVotingRequestService: FeatureVotingRequestService,
        featureVotingCacheService: FeatureVotingCacheService,
        featuresService: FeaturesService
    ) {
        
        self.featureVotingRequestService = featureVotingRequestService
        self.featureVotingCacheService = featureVotingCacheService
        self.featuresService = featuresService
    }
}

extension FeatureServiceRunner {
    
    func run() {
        
        print("[Feature][🔵] Starting sync process...")
        
        featuresToUpdate = Web3FeatureData.allFeatures
        
        fetchNext()
    }
}

private extension FeatureServiceRunner {
    
    func fetchNext() {
        
        guard let feature = featuresToUpdate.first else {
            
            return generateJSONData()
        }
        
        fetch(feature: feature)
    }
    
    
    func fetch(feature: Web3FeatureData) {
        
        guard Thread.isMainThread else {
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.fetch(feature: feature)
            }
            return
        }
        
        let meta = featureVotingCacheService.metadata(for: feature)
        print("[Feature][🟠][\(feature.hashTag)] Cached meta votes: \(meta?.votes ?? 0)")
        print("[Feature][↗️][\(feature.hashTag)] Fetching votes...")
        
        featureVotingRequestService.fetchVotes(for: feature, sinceId: meta?.latestId) { [weak self] result in
            guard let self = self else { return }
            switch result {
                
            case let .success(data):
                
                print("[Feature][✅][\(feature.hashTag)] 1 - Success with total votes: \(data?.totalVotes ?? 0).")
                
                guard let data = data, data.totalVotes > 0 else {
                
                    print("[Feature][✅][\(feature.hashTag)] 2 - No more votes so moving next.")
                    return self.removeFeatureAndGoNext(feature: feature)
                }
                
                let newMeta = FeatureVotingCacheMeta(
                    hashTag: feature.hashTag,
                    votes: (meta?.votes ?? 0) + data.totalVotes,
                    latestId: data.latestId
                )
                print("[Feature][✅][\(feature.hashTag)] 2 - Caching new metadata \(newMeta).")
                self.featureVotingCacheService.store(metadata: newMeta)

                guard data.hasMoreVotes else {
                    
                    print("[Feature][✅][\(feature.hashTag)] 3 - No more votes so moving next.")
                    return self.removeFeatureAndGoNext(feature: feature)
                }
                
                print("[Feature][✅][\(feature.hashTag)] 3 - Still more votes so fetching again.")
                
                self.fetch(feature: feature)

                
            case .failure:
                
                print("[Feature][❌][\(feature.hashTag)] 1 - Moving to next feature")
                self.removeFeatureAndGoNext(feature: feature)
            }
        }
    }
    
    func removeFeatureAndGoNext(feature: Web3FeatureData) {
        
        guard Thread.isMainThread else {
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.removeFeatureAndGoNext(feature: feature)
            }
            return
        }
        
        featuresToUpdate.removeAll { feature.id == $0.id }
        fetchNext()
    }
}

private extension FeatureServiceRunner {
    
    func generateJSONData() {
        
        print("[Feature][➡️] Generating JSON File...")
        featuresService.fetchAllFeatures { result in
            
            switch result {
                
            case let .success(features):
                
                let paths = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
                let cachesDirectory: URL = URL(string: "\(paths[0].absoluteString)web3wallet-improvement-proposals.json")!
                                
                let jsonData = try! JSONEncoder().encode(features)
                try! jsonData.write(to: cachesDirectory)
                
                print("[Feature][✅] JSON File generated and stored at: \(cachesDirectory.absoluteString)")

            case let .failure(error):
                print("[Feature][❌][Failed] Unable to generate JSON file with error: \(error.localizedDescription)!")
            }
        }
        print("[Feature][➡️] Generate JSON File!")
    }
}
