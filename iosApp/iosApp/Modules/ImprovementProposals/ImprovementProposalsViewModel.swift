// Created by web3d3v on 30/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import UIKit

enum ImprovementProposalsViewModel {
    case loading
    case loaded(sections: [Section], selectedSectionType: Section.`Type`)
    case error(error: AppsViewModel.Error)
}

extension ImprovementProposalsViewModel {
    
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
                    return Localized("proposals.segmentedControl.all")
                case .infrastructure:
                    return Localized("proposals.segmentedControl.infrastructure")
                case .integrations:
                    return Localized("proposals.segmentedControl.integrations")
                case .features:
                    return Localized("proposals.segmentedControl.features")
                }
            }
            
            var descriptionValue: String {
                switch self {
                case .all:
                    return Localized("proposals.section.all.description")
                case .infrastructure:
                    return Localized("proposals.section.infrastructure.description")
                case .integrations:
                    return Localized("proposals.section.integrations.description")
                case .features:
                    return Localized("proposals.section.features.description")
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

extension ImprovementProposalsViewModel {

    struct Error {
        let title: String
        let body: String
        let actions: [String]
    }
}

extension ImprovementProposalsViewModel {
    
    var title: String {
        Localized("proposals.title")
    }
    
    var sections: [ImprovementProposalsViewModel.Section] {
        
        switch self {
        case let .loaded(sections, _): return sections
        default: return []
        }
    }
    
    var selectedSectionType: ImprovementProposalsViewModel.Section.`Type` {
        switch self {
        case let .loaded(_, type): return type
        default: return .all
        }
    }
}

extension ImprovementProposalsViewModel.Section.`Type` {

    static func from(
        _ category: ImprovementProposal.Category
    ) -> ImprovementProposalsViewModel.Section.`Type` {
        switch category {
        case .infrastructure: return .infrastructure
        case .integration: return .integrations
        case .feature: return .features
        default: return .all
        }
    }
}
