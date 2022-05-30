// Created by web3d4v on 24/05/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

protocol NFTsDashboardInteractor: AnyObject {

    func fetchYourNFTs(
        onCompletion: (Result<[NFTItem], Error>) -> Void
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
    
    func fetchYourNFTs(onCompletion: (Result<[NFTItem], Error>) -> Void) {
        
        service.yourNFTs(onCompletion: onCompletion)
    }
    
    func fetchYourNFTsCollections(onCompletion: (Result<[NFTCollection], Error>) -> Void) {
        
        service.yourNftCollections(onCompletion: onCompletion)
    }
}
