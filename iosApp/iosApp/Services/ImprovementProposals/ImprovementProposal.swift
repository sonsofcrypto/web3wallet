// Created by web3d4v on 15/08/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

enum ImprovementProposalError: Error {
    case categoryNotDefined
}

struct ImprovementProposal: Codable, Equatable {
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case body
        case category
        case atAccount = "at_account"
        case tweet
        case imageUrl = "image_url"
        case pageUrl = "page_url"
        case creationDate = "creation_date"
        case votes
    }
    
    let id: String
    let title: String
    let body: String
    let category: Category
    let atAccount: String?
    let tweet: String
    let imageUrl: String
    let pageUrl: String
    let creationDate: String // "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    let votes: Int

    enum Category: String, Equatable, CaseIterable {
        case infrastructure
        case integration
        case feature
        case unknown
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        body = try container.decode(String.self, forKey: .body)
        let category = try container.decode(String.self, forKey: .category)
        self.category = Category(rawValue: category) ?? .unknown
        atAccount = try? container.decode(String.self, forKey: .atAccount)
        tweet = try container.decode(String.self, forKey: .tweet)
        imageUrl = try container.decode(String.self, forKey: .imageUrl)
        pageUrl = try container.decode(String.self, forKey: .pageUrl)
        creationDate = try container.decode(String.self, forKey: .creationDate)
        votes = try container.decode(Int.self, forKey: .votes)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(body, forKey: .body)
        try container.encode(category.rawValue, forKey: .category)
        try container.encode(atAccount, forKey: .atAccount)
        try container.encode(imageUrl, forKey: .imageUrl)
        try container.encode(pageUrl, forKey: .pageUrl)
        try container.encode(creationDate, forKey: .creationDate)
        try container.encode(votes, forKey: .votes)
    }
}

extension ImprovementProposal {
    var hashTag: String { Localized("feature.hashTag", arg: id) }
}

extension ImprovementProposal.Category {
    var stringValue: String {
        switch self {
        case .infrastructure:
            return Localized("features.segmentedControl.infrastructure")
        case .integration:
            return Localized("features.segmentedControl.integrations")
        case .feature:
            return Localized("features.segmentedControl.features")
        case .unknown:
            return Localized("features.segmentedControl.unknown")
        }
    }
}
