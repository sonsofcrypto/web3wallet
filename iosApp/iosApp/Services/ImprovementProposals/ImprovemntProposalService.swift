// Created by web3d4v on 27/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

enum ImprovementProposalsServiceErrors: Error {
    case unableToFetch
}

typealias ProposalsHandler = (Result<[ImprovementProposal], Error>) -> Void

protocol ImprovementProposalsService {
    func fetchProposals(handler: @escaping ProposalsHandler)
}

final class DefaultFeaturesService {
    let defaults: UserDefaults
    
    init(defaults: UserDefaults) {
        self.defaults = defaults
    }
}

extension DefaultFeaturesService: ImprovementProposalsService {
    
    func fetchProposals(handler: @escaping ProposalsHandler) {
        URLSession.shared.dataTask(with: url()) { (data, response, error) in
            if let error = error {
                return self.cachedProposals(error: error, handler: handler)
            }
            guard let data = data else {
                let error = ImprovementProposalsServiceErrors.unableToFetch
                return self.cachedProposals(error: error, handler: handler)
            }

            do {
                let result = try JSONDecoder().decode([ImprovementProposal].self, from: data)
                    .sorted(by: { $0.id < $1.id })
                self.storeResults(result)
                DispatchQueue.main.async { handler(.success(result)) }
            } catch let error {
                self.cachedProposals(error: error, handler: handler)
            }
        }.resume()
    }
}

private extension DefaultFeaturesService {
    
    func url() -> URL! {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "raw.githubusercontent.com"
        urlComponents.path = "/sonsofcrypto/web3wallet-improvement-proposals/master/proposals-list.json"
        return urlComponents.url!
    }

    func storeResults(_ features: [ImprovementProposal]) {
        guard let data = try? JSONEncoder().encode(features) else { return }
        DispatchQueue.main.async {
            self.defaults.set(data, forKey: Constant.cachedKey)
            self.defaults.synchronize()
        }
    }
    
    func cachedProposals(error: Error, handler: @escaping ProposalsHandler) {
        guard let data = defaults.data(forKey: Constant.cachedKey) else {
            return DispatchQueue.main.async { handler(.failure(error)) }
        }
        
        do {
            let result = try JSONDecoder().decode([ImprovementProposal].self, from: data)
            DispatchQueue.main.async { handler(.success(result)) }
        } catch let error {
            DispatchQueue.main.async { handler(.failure(error)) }
        }
    }
}

enum Constant {
    static let cachedKey: String = "w3w-improvement-proposals-list"

}
