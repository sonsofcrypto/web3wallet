// Created by web3d4v on 15/08/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

enum Web3FeatureError: Error {
    
    case categoryNotDefined
}

struct Web3Feature: Codable, Equatable {
    
    enum CodingKeys: String, CodingKey {
        
        case id
        case title
        case body
        case imageUrl = "image_url"
        case category
        case creationDate = "creation_date"
        case votes
    }
    
    let id: String
    let title: String
    let body: String
    let imageUrl: String // asset n ame in project bundle
    let category: Category
    // UTC time for when we should start searching for votes
    let creationDate: String // "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    // let endDate: Date // UTC (not using this yet)
    let votes: Int
    
    enum Category: String, Equatable {
        
        case infrastructure
        case integrations
        case features
    }
    
    init(
        id: String,
        title: String,
        body: String,
        imageUrl: String,
        category: Category,
        creationDate: String,
        votes: Int
    ) {

        self.id = id
        self.title = title
        self.body = body
        self.imageUrl = imageUrl
        self.category = category
        self.creationDate = creationDate
        self.votes = votes
    }
    
    func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(body, forKey: .body)
        try container.encode(imageUrl, forKey: .imageUrl)
        try container.encode(category.rawValue, forKey: .category)
        try container.encode(creationDate, forKey: .creationDate)
        try container.encode(votes, forKey: .votes)
    }
    
    init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        body = try container.decode(String.self, forKey: .body)
        imageUrl = try container.decode(String.self, forKey: .imageUrl)
        let category = try container.decode(String.self, forKey: .category)
        switch category {
        case Category.infrastructure.rawValue:
            self.category = .infrastructure
        case Category.integrations.rawValue:
            self.category = .integrations
        case Category.features.rawValue:
            self.category = .features
        default:
            throw Web3FeatureError.categoryNotDefined
        }
        creationDate = try container.decode(String.self, forKey: .creationDate)
        votes = try container.decode(Int.self, forKey: .votes)
    }
}

extension Web3Feature {
    
    var hashTag: String {
        
        Localized("feature.hashTag", arg: id)
    }
}

extension Web3Feature.Category {
    
    var stringValue: String {
        
        switch self {
            
        case .infrastructure:
            return Localized("features.segmentedControl.infrastructure")
        case .integrations:
            return Localized("features.segmentedControl.integrations")
        case .features:
            return Localized("features.segmentedControl.infrastructure")
        }
    }
}
