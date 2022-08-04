// Created by web3d4v on 24/05/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

protocol NFTsDashboardInteractor: AnyObject {

    func fetchYourNFTs(
        isPullDownToRefreh: Bool,
        onCompletion: @escaping (Result<[NFTItem], Error>) -> Void
    )
    func fetchYourNFTsCollections(
        onCompletion: (Result<[NFTCollection], Error>) -> Void
    )
}

final class DefaultNFTsDashboardInteractor {

    private var service: NFTsService

    init(service: NFTsService) {
        
        self.service = service
    }
}

extension DefaultNFTsDashboardInteractor: NFTsDashboardInteractor {
    
    func fetchYourNFTs(
        isPullDownToRefreh: Bool,
        onCompletion: @escaping (Result<[NFTItem], Error>) -> Void
    ) {
        
        guard !isPullDownToRefreh else {
            
            service.fetchNFTs(onCompletion: onCompletion)
            return
        }
        
        guard service.yourNFTs().isEmpty else {
            
            onCompletion(.success(service.yourNFTs()))
            return
        }
        
        service.fetchNFTs(onCompletion: onCompletion)
    }
    
    func fetchYourNFTsCollections(onCompletion: (Result<[NFTCollection], Error>) -> Void) {
        
        service.yourNftCollections(onCompletion: onCompletion)
    }
}
