// Created by web3d3v on 30/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import UIKit

enum FeaturesViewModel {
    case loading
    case loaded(sections: [Section], selectedSectionType: Section.`Type`)
    case error(error: AppsViewModel.Error)
}

extension FeaturesViewModel {
    
    struct Section {
        
        let title: String
        let type: `Type`
        let items: [Item]
        let footer: Footer?
        
        enum `Type` {
            case all
            case infrastructure
            case integrations
            case features
            
            var stringValue: String {
                
                switch self {
                case .all:
                    return Localized("features.segmentedControl.all")
                case .infrastructure:
                    return Localized("features.segmentedControl.infrastructure")
                case .integrations:
                    return Localized("features.segmentedControl.integrations")
                case .features:
                    return Localized("features.segmentedControl.features")
                }
            }
        }
        
        struct Footer {
            
            let imageName: String
            let text: String
        }
    }

    struct Item {
        
        let id: String
        let title: String
        let totalVotes: String
        let totalVotesValue: String
        let category: String?
        let categoryValue: String?
        let voteButtonTitle: String
    }
}

extension FeaturesViewModel {

    struct Error {
        
        let title: String
        let body: String
        let actions: [String]
    }
}

extension FeaturesViewModel {
    
    var title: String {
        Localized("features.title")
    }
    
    var sections: [FeaturesViewModel.Section] {
        
        switch self {
        case let .loaded(sections, _):
            return sections
        default:
            return []
        }
    }
    
    var selectedSectionType: FeaturesViewModel.Section.`Type` {
        
        switch self {
        case let .loaded(_, type):
            return type
        default:
            return .all
        }
    }
}
