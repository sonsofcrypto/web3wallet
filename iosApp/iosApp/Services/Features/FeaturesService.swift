// Created by web3d4v on 27/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

enum FeaturesServiceErrors: Error {
    
    case unableToFetch
}

protocol FeaturesService {
    
    func fetchAllFeatures(onCompletion: @escaping (Result<[Web3Feature], Error>) -> Void)
}

final class DefaultFeaturesService {
    
    let featureVotingCacheService: FeatureVotingCacheService
    let defaults: UserDefaults
    
    init(
        featureVotingCacheService: FeatureVotingCacheService,
        defaults: UserDefaults
    ) {
        
        self.featureVotingCacheService = featureVotingCacheService
        self.defaults = defaults
    }
}

extension DefaultFeaturesService: FeaturesService {
    
    func fetchAllFeatures(onCompletion: @escaping (Result<[Web3Feature], Error>) -> Void) {
        
        guard let url = makeDownloadUrl() else {
            
            let error = FeaturesServiceErrors.unableToFetch
            return returnCachedListOrError(error: error, onCompletion: onCompletion)
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            DispatchQueue.main.async { [weak self] in
                
                guard let self = self else { return }
                
                if let error = error {
                    
                    return self.returnCachedListOrError(error: error, onCompletion: onCompletion)
                }
                
                guard let data = data else {
                    
                    let error = FeaturesServiceErrors.unableToFetch
                    return self.returnCachedListOrError(error: error, onCompletion: onCompletion)
                }
                
                do {
                    let result = try JSONDecoder().decode([Web3Feature].self, from: data)
                    self.storeResults(result)
                    onCompletion(.success(result))
                    
                } catch let error {
                    
                    self.returnCachedListOrError(error: error, onCompletion: onCompletion)
                }
            }
        }.resume()
    }
}

private extension DefaultFeaturesService {
    
    func makeDownloadUrl() -> URL? {
        
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "raw.githubusercontent.com"
        urlComponents.path = "/sonsofcrypto/web3wallet-improvement-proposals/master/proposals-list.json"
        return urlComponents.url
    }
    
    var userDefaultsCachedKey: String { "w3w-improvement-proposals-list" }
    
    func storeResults(_ features: [Web3Feature]) {
        
        guard let data = try? JSONEncoder().encode(features) else { return }
        defaults.set(data, forKey: userDefaultsCachedKey)
    }
    
    func returnCachedListOrError(
        error: Error,
        onCompletion: @escaping (Result<[Web3Feature], Error>) -> Void
    ) {
        
        guard let data = defaults.data(forKey: userDefaultsCachedKey) else {
            
            onCompletion(.failure(error))
            return
        }
        
        do {
            let result = try JSONDecoder().decode([Web3Feature].self, from: data)
            onCompletion(.success(result))
        } catch let error {
            
            onCompletion(.failure(error))
        }
    }
}
