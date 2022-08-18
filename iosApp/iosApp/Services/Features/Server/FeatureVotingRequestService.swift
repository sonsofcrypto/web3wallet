// Created by web3d4v on 17/08/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

/**
 * Using Twitter API to check latest votes
 * 1 - https://api.twitter.com/2/tweets/search/recent?query=#WIP1001&since_id=<XXXX>
 */

// TODO: Move this to generic Networking errors when moved to Kotlin
enum FeatureVotingRequestServiceError: Error {
    
    case unableToConstructURL
    case failedToDownload
    case notFound
}

protocol FeatureVotingRequestService {
    
    func fetchVotes(
        for feature: Web3FeatureData,
        sinceId: String?,
        onCompletion: @escaping (Result<FeatureVoteResult?, Error>) -> Void
    )
}

struct FeatureVoteResult {
    
    let totalVotes: Int
    let latestId: String
    let hasMoreVotes: Bool
}

final class TwitterFeatureVotingRequestService: FeatureVotingRequestService {
    
    func fetchVotes(
        for feature: Web3FeatureData,
        sinceId: String?,
        onCompletion: @escaping (Result<FeatureVoteResult?, Error>) -> Void
    ) {
        
        let requestDetails: TwitterFeatureVotingRequestService.Details
        if let sinceId = sinceId {
            requestDetails = .votesSinceId(hashtag: feature.hashTag, sinceId: sinceId)
        } else {
            requestDetails = .votesFrom(hashtag: feature.hashTag, startTime: feature.creationDate)
        }
        
        guard let urlRequest = makeURLRequest(for: requestDetails) else {

            onCompletion(.failure(FeatureVotingRequestServiceError.unableToConstructURL))
            return
        }
        
        URLSession.shared.dataTask(with: urlRequest) { data, _, error in

            guard let data = data else {

                onCompletion(.failure(error ?? FeatureVotingRequestServiceError.failedToDownload))
                return
            }

            do {

                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                
                //print("[Feature][Data] Response -> \(String(data: data, encoding: .utf8))")
                
                let data = try decoder.decode(TweetSearchRecentRespoonse.self, from: data)
                
                var result: FeatureVoteResult?
                if let newestId = data.meta.newestId {
                   result = .init(
                        totalVotes: data.meta.resultCount,
                        latestId: newestId,
                        hasMoreVotes: data.meta.resultCount == self.maxResults
                   )
                }
                
                DispatchQueue.main.async {
                    onCompletion(.success(result))
                }
            } catch {
                DispatchQueue.main.async {
                    onCompletion(.failure(error))
                }
            }
        }.resume()
    }
}

private extension TwitterFeatureVotingRequestService {
    
    var host: String { "api.twitter.com" }
    var BEARER_TOKEN: String { "" }
    var maxResults: Int { 100 }
    
    enum Details {
        
        case votesFrom(hashtag: String, startTime: String)
        case votesSinceId(hashtag: String, sinceId: String)
        
        var path: String {
            
            switch self {
            case .votesFrom, .votesSinceId:
                return "/2/tweets/search/recent"
            }
        }
    }
    
    func makeURLRequest(
        for details: Details
    ) -> URLRequest? {
        
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = host
        
        switch details {
            
        case let .votesFrom(hashtag, startTime):
            urlComponents.path = details.path
            urlComponents.queryItems = [
                .init(name: "query", value: hashtag),
                .init(name: "start_time", value: startTime), // ISO 8601
                .init(name: "max_results", value: "100")
            ]
        case let .votesSinceId(hashtag, sinceId):
            urlComponents.path = details.path
            urlComponents.queryItems = [
                .init(name: "query", value: hashtag),
                .init(name: "since_id", value: sinceId),
                .init(name: "max_results", value: "\(maxResults)")
            ]
        }
        
        guard let url = urlComponents.url else { return nil }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.allHTTPHeaderFields = [
            "Authorization": "Bearer \(BEARER_TOKEN)",
            "Accept": "application/json"
        ]
        
        return urlRequest
    }
}

private struct TweetSearchRecentRespoonse: Codable {
    
    let meta: Metadata
    let data: [Data]?
    
    struct Metadata: Codable {
        
        let resultCount: Int
        let newestId: String?
        let oldestId: String?
    }
    
    struct Data: Codable {
     
        let id: String
        let text: String
        let authorId: String?
        let lang: String?
        let conversationId: String?
        let createdAt: String?
    }
}
