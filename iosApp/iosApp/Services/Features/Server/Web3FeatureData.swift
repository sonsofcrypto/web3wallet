// Created by web3d4v on 15/08/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

struct Web3FeatureData: Equatable {
    
    let id: String
    let title: String
    let body: String
    let image: String // asset name in project bundle
    let category: Web3Feature.Category
    let creationDate: Date // UTC time for when we should start searching for votes
}

extension Web3FeatureData {
    
    var hashTag: String {
        
        "#\(Localized("feature.hashTag", arg: id))"
    }
    
    static var allFeatures: [Web3FeatureData] {
        
        [
            .init(
                id: "abcde12345",
                title: "This is now a long title to test what happens",
                body: "This is actually much cooler that you may think. Stay tunned!",
                image: "",
                category: .infrastructure,
                creationDate: "2022-08-11T00:00:00.000Z".date() ?? Date()
            ),
            .init(
                id: "1001",
                title: "Feature 2",
                body: "Anoon will this with exciting details, this is gonna be a very long description, he loves to write!",
                image: "",
                category: .infrastructure,
                creationDate: "2022-08-15T00:00:00.000Z".date() ?? Date()
            ),
            .init(
                id: "2001",
                title: "Feature 3",
                body: "Anoon will this with exciting details, this is gonna be a very long description, he loves to write!",
                image: "dashboard-palm",
                category: .integrations,
                creationDate: "2022-08-15T00:00:00.000Z".date() ?? Date()
            ),
            .init(
                id: "3001",
                title: "Feature 4",
                body: "Anoon will this with exciting details, this is gonna be a very long description, he loves to write!",
                image: "dashboard-palm",
                category: .features,
                creationDate: "2022-08-15T00:00:00.000Z".date() ?? Date()
            )
        ]
    }
}
