// Created by web3d4v on 15/08/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

struct Web3Feature: Codable, Equatable {
    
    let id: String
    let title: String
    let body: String
    let image: String // asset name in project bundle
    let category: Category
    let creationDate: Date // UTC time for when we should start searching for votes
    // let endDate: Date // UTC (not using this yet)
    let votes: Int
    
    enum Category: Codable, Equatable {
        
        case infrastructure
        case integrations
        case features
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
