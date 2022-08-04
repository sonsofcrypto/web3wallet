// Created by web3d3v on 18/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

protocol NFTsService: AnyObject {

    func nft(
        with identifier: String,
        onCompletion: (Result<NFTItem, Error>) -> Void
    )
    func collection(
        with identifier: String,
        onCompletion: (Result<NFTCollection, Error>) -> Void
    )
    func fetchNFTs(
        onCompletion: @escaping (Result<[NFTItem], Error>) -> Void
    )
    func yourNFTs(
        forCollection collection: String,
        onCompletion: (Result<[NFTItem], Error>) -> Void
    )
    func yourNftCollections(
        onCompletion: (Result<[NFTCollection], Error>) -> Void
    )
    func yourNFTs(
        forNetwork network: Web3Network
    ) -> [NFTItem]
    
    func yourNFTs() -> [NFTItem]
}

struct NFTItem {
    
    let identifier: String
    let collectionIdentifier: String
    let name: String
    let properties: [Property]
    /** URL pointing to the NFT image **/
    let image: String
    
    struct Property {
        
        let name: String
        let value: String
        let info: String
    }
}

struct NFTCollection {
    
    let identifier: String
    
    /** URL pointing to the cover image for this collection **/
    let coverImage: String

    /** Title for the collection **/
    let title: String

    /** Author of the collection **/
    let author: String

    /** Flag determinig if the account is verified or not **/
    let isVerifiedAccount: Bool

    /** URL pointing to the author image of the collection **/
    let authorImage: String
    
    /** Descriptoin of the collection **/
    let description: String
}
