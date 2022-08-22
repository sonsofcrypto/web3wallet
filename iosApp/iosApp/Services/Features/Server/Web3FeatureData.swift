// Created by web3d4v on 15/08/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

struct Web3FeatureData: Equatable {
    
    let id: String
    let title: String
    let body: String
    let imageUrl: String // URL pointing to a valid image in imgur, eg: https://imgur.com/gallery/XXXXX
    let category: Web3Feature.Category
    let creationDate: String // UTC time for when we should start searching for votes
}

extension Web3FeatureData {
    
    var hashTag: String {

        "#\(Localized("feature.hashTag", arg: id))"
    }
    
    static var allFeatures: [Web3FeatureData] {
        
        [
            .init(
                id: "1002",
                title: "Matic support",
                body: "Matic support description, TBC",
                imageUrl: "https://imgur.com/gallery/jX0vvpz",
                category: .infrastructure,
                creationDate: "2022-08-18T00:00:00.000Z"
            ),
            .init(
                id: "1001",
                title: "Solana support",
                body: "Solana support description, TBC",
                imageUrl: "https://imgur.com/gallery/jX0vvpz",
                category: .infrastructure,
                creationDate: "2022-08-18T00:00:00.000Z"
            ),
            .init(
                id: "2001",
                title: "Integration 1",
                body: "Integration 1 description, TBC",
                imageUrl: "https://imgur.com/gallery/jX0vvpz",
                category: .integrations,
                creationDate: "2022-08-18T00:00:00.000Z"
            ),
            .init(
                id: "3001",
                title: "Currency Swap",
                body: "Currency Swap description, TBC",
                imageUrl: "https://imgur.com/gallery/jX0vvpz",
                category: .features,
                creationDate: "2022-08-18T00:00:00.000Z"
            )
        ]
    }
}
