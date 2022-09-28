// Created by web3d4v on 29/05/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

protocol NFTsCollectionInteractor: AnyObject {
    func fetchCollection(
        with identifier: String,
        onCompletion: (Result<NFTCollection, Error>) -> Void
    )
    func fetchNFTs(
        forCollection identifier: String,
        onCompletion: (Result<[NFTItem], Error>) -> Void
    )
}

final class DefaultNFTsCollectionInteractor {
    private var service: NFTsService

    init(service: NFTsService) {
        self.service = service
    }
}

extension DefaultNFTsCollectionInteractor: NFTsCollectionInteractor {
    
    func fetchCollection(
        with identifier: String,
        onCompletion: (Result<NFTCollection, Error>) -> Void
    ) {
        service.collection(with: identifier, onCompletion: onCompletion)
    }
    
    func fetchNFTs(
        forCollection identifier: String,
        onCompletion: (Result<[NFTItem], Error>) -> Void
    ) {
        service.yourNFTs(forCollection: identifier, onCompletion: onCompletion)
    }
}
