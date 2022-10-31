// Created by web3d4v on 27/05/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3walletcore

protocol NFTDetailInteractor: AnyObject {
    func fetchNFT(
        with identifier: String,
        onCompletion: (Result<NFTItem, Error>) -> Void
    )
    func fetchNFTCollection(
        with identifier: String,
        onCompletion: (Result<NFTCollection, Error>) -> Void
    )
}

final class DefaultNFTDetailInteractor {
    private var service: NFTsService
    init(service: NFTsService) {
        self.service = service
    }
}

extension DefaultNFTDetailInteractor: NFTDetailInteractor {
    
    func fetchNFT(
        with identifier: String,
        onCompletion: (Result<NFTItem, Error>) -> Void
    ) {
        onCompletion(.success(service.nft(identifier: identifier)))
    }
    
    func fetchNFTCollection(
        with identifier: String,
        onCompletion: (Result<NFTCollection, Error>) -> Void
    ) {
        onCompletion(.success(service.collection(identifier: identifier)))
    }
}
