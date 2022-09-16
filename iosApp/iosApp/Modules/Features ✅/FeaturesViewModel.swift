// Created by web3d3v on 30/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import UIKit

enum FeaturesViewModel {
    case loading
    case loaded(sections: [Section], selectedSectionType: Section.`Type`)
    // TODO: We should use AlertViewModel instead of AppsViewModel.Error...
    case error(error: AppsViewModel.Error)
}

extension FeaturesViewModel {
    
    struct Section {
        let title: String
        let description: String
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
            
            var descriptionValue: String {
                switch self {
                case .all:
                    return Localized("features.section.all.description")
                case .infrastructure:
                    return Localized("features.section.infrastructure.description")
                case .integrations:
                    return Localized("features.section.integrations.description")
                case .features:
                    return Localized("features.section.features.description")
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
        let subtitle: String
        let buttonTitle: String
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
