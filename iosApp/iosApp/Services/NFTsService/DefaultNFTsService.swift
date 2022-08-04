// Created by web3d4v on 27/05/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

final class DefaultNFTsService {

}

extension DefaultNFTsService: NFTsService {
    
    func fetchNFTs(onCompletion: @escaping (Result<[NFTItem], Error>) -> Void) {
        
    }
    
    func yourNFTs() -> [NFTItem] {
        []
    }
    
    
    func nft(
        with identifier: String,
        onCompletion: (Result<NFTItem, Error>) -> Void
    ) {
        
        yourNFTs { result in
            switch result {
            case let .success(nfts):
                let nftItem = nfts.filter { $0.identifier == identifier }.first
                guard let nftItem = nftItem else { fatalError("This should never happen") }
                onCompletion(.success(nftItem))
            case .failure:
                break
            }
        }
    }
    
    func collection(
        with identifier: String,
        onCompletion: (Result<NFTCollection, Error>) -> Void
    ) {
        
        yourNftCollections { result in
            switch result {
            case let .success(collections):
                let nftCollection = collections.filter { $0.identifier == identifier }.first
                guard let nftCollection = nftCollection else { fatalError("This should never happen") }
                onCompletion(.success(nftCollection))
            case .failure:
                break
            }
        }
    }
    
    func yourNFTs(
        onCompletion: (Result<[NFTItem], Error>) -> Void
    ) {
        
        onCompletion(.success(Self.yourNFTs))
    }
    
    func yourNFTs(
        forCollection collectionId: String,
        onCompletion: (Result<[NFTItem], Error>) -> Void
    ) {
        
        let nfts = Self.yourNFTs.filter {
            $0.collectionIdentifier == collectionId
        }
        onCompletion(.success(nfts))
    }

    func yourNftCollections(
        onCompletion: (Result<[NFTCollection], Error>) -> Void
    ) {
        
        onCompletion(.success(Self.yourNFTCollections))
    }
    
    func yourNFTs(
        forNetwork network: Web3Network
    ) -> [NFTItem] {
        
        switch network.name.lowercased() {
            
        case "ethereum":
            
            return Self.yourNFTs
        default:
            
            return []
        }
    }
}
