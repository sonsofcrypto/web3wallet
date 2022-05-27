// Created by web3d4v on 16/05/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

final class DefaultNFTsService {

}

extension DefaultNFTsService: NFTsService {
    
    func yourNFTs(
        onCompletion: (Result<[NFTItem], Error>) -> Void
    ) {
        
        onCompletion(.success(Self.yourNFTs))
    }

    func yourNftsCollections(
        onCompletion: (Result<[NFTCollection], Error>) -> Void
    ) {
        
        onCompletion(.success(Self.yourNFTCollections))
    }
}
