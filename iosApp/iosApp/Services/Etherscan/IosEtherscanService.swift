// Created by web3d4v on 05/08/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3lib

struct EtherscanTransactionResponse: Codable {
    let status: String
    let message: String
    let result: [EtherscanTransaction]
}

struct EtherscanTransaction: Codable {
    let blockNumber: String
    let timeStamp: String
    let hash: String
    let nonce: String
    let blockHash: String
    let transactionIndex: String
    let from: String
    let to: String
    let value: String
    let gas: String
    let gasPrice: String
    let isError: String
    let txreceiptStatus: String
    let input: String
    let contractAddress: String
    let cumulativeGasUsed: String
    let gasUsed: String
    let confirmations: String
    let methodId: String
    let functionName: String
}

enum EtherscanServiceError: Error {
    
    case unableToConstructURL
    case failedToDownload
}

protocol IosEtherscanService {

    func cachedTransactionHistory(
        for walletAddress: String,
        network: Network,
        nonce: String
    ) -> [EtherscanTransaction]
    
    func fetchTransactionHistory(
        for address: String,
        network: Network,
        onCompletion: @escaping (Result<[EtherscanTransaction], Error>) -> Void
    )
}

final class DefaultIosEtherscanService {
    
    private let networksService: NetworksService
    private let defaults: UserDefaults
    
    private let LATEST_FILE_NAME = "EtherScanFileNameCached"
    private let API_KEY = DefaultEtherScanService().apiKey()
    
    init(
        networksService: NetworksService,
        defaults: UserDefaults = .standard
    ) {
        self.networksService = networksService
        self.defaults = defaults
    }
}

extension DefaultIosEtherscanService: IosEtherscanService {
    
    func cachedTransactionHistory(
        for walletAddress: String,
        network: Network,
        nonce: String
    ) -> [EtherscanTransaction] {
        
        let transactionFileTarget = makeFileName(
            for: walletAddress,
            network: network,
            nonce: nonce
        )
        let transactionFileCached = defaults.string(forKey: LATEST_FILE_NAME)
        
        guard transactionFileTarget == transactionFileCached else {
            clearCache()
            return []
        }
        
        guard let data = defaults.data(forKey: transactionFileTarget) else {
            clearCache()
            return []
        }
        
        guard let transactions = try? loadTransactions(from: data) else {
            clearCache()
            return []
        }
        
        return transactions
    }
    
    func fetchTransactionHistory(
        for walletAddress: String,
        network: Network,
        onCompletion: @escaping (Result<[EtherscanTransaction], Error>) -> Void
    ) {
        
        guard let urlRequest = makeURLRequest(
            for: .transactions(address: walletAddress),
            network: network
        ) else {
            onCompletion(.failure(EtherscanServiceError.unableToConstructURL))
            return
        }
        
        URLSession.shared.dataTask(with: urlRequest) { [weak self] data, _, error in
            guard let self = self else { return }
            guard let data = data else {
                onCompletion(.failure(error ?? EtherscanServiceError.failedToDownload))
                return
            }

            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let transactions = try decoder.decode(
                    EtherscanTransactionResponse.self,
                    from: data
                ).result
                
                try self.storeNewTransactions(
                    with: walletAddress,
                    network: network,
                    and: transactions
                )
                
                DispatchQueue.main.async {
                    onCompletion(.success(transactions))
                }
            } catch {
                DispatchQueue.main.async {
                    onCompletion(.failure(error))
                }
            }
        }.resume()
    }
}

private extension DefaultIosEtherscanService {
    
    func clearCache() {
        guard let transactionFileCached = defaults.string(forKey: LATEST_FILE_NAME) else {
            
            return
        }
        defaults.removeObject(forKey: transactionFileCached)
        defaults.synchronize()
    }
    
    func makeFileName(for wallet: String, network: Network, nonce: String) -> String {
        "\(wallet)_\(network)_\(nonce)"
    }
    
    func storeNewTransactions(
        with walletAddress: String,
        network: Network,
        and transactions: [EtherscanTransaction]
    ) throws {
        
        guard let nonce = try? transactions.first?.nonce.int() else { return }
        
        let fileName = makeFileName(
            for: walletAddress,
            network: network,
            nonce: "\(nonce + 1)"
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(transactions)
        
        clearCache()
        
        defaults.set(fileName, forKey: LATEST_FILE_NAME)
        defaults.set(data, forKey: fileName)
        defaults.synchronize()
    }
    
    func loadTransactions(from data: Data) throws -> [EtherscanTransaction] {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(
            [EtherscanTransaction].self,
            from: data
        )
    }
}

private extension DefaultIosEtherscanService {
    
    func host(_ network: Network) -> String {
        switch network.chainId {
        case 3: return "api-ropsten.etherscan.io"
        case 4: return "api-rinkeby.etherscan.io"
        case 5: return "api-goerli.etherscan.io"
        default: return "api.etherscan.io"
        }
    }
    
    enum Details {
        case transactions(
            address: String
        )
        
        var path: String {
            switch self {
            case .transactions:
                return "/api"
            }
        }
    }
    
    func makeURLRequest(
        for details: Details,
        network: Network
    ) -> URLRequest? {
        
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = host(network)
        
        switch details {
        case let .transactions(address):
            urlComponents.path = details.path
            urlComponents.queryItems = [
                .init(name: "module", value: "account"),
                .init(name: "action", value: "txlist"),
                .init(name: "address", value: address),
                .init(name: "sort", value: "desc")
            ]
            if !API_KEY.isEmpty {
                urlComponents.queryItems?.append(
                    .init(name: "apikey", value: API_KEY)
                )
            }
        }
        
        guard let url = urlComponents.url else { return nil }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.allHTTPHeaderFields = [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        return urlRequest
    }
}
