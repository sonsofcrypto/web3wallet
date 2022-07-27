// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import UIKit

enum CultProposalsViewModel {
    case loading
    case loaded(sections: [Section], selectedSectionType: Section.`Type`)
    case error(error: AppsViewModel.Error)
}

extension CultProposalsViewModel {
    
    struct Section {
        
        let title: String
        let type: `Type`
        let items: [Item]
        
        enum `Type` {
            case pending
            case closed
        }
    }

    struct Item {
        
        let id: String
        let title: String
        let approved: Vote
        let rejected: Vote
        let approveButtonTitle: String
        let rejectButtonTitle: String
        let endDate: Date
        
        struct Vote {
            
            let name: String
            let value: Double
            let total: Double
            let type: `Type`
            
            enum `Type` {
                
                case approved
                case rejected
            }
        }
    }
}

extension CultProposalsViewModel {

    struct Error {
        
        let title: String
        let body: String
        let actions: [String]
    }
}

extension CultProposalsViewModel {
    
    var title: String {
        Localized("cult.proposals.title")
    }
    
    var titleIcon: Data {
        
        UIImage(named: "degen-cult-icon")!.pngData()!
    }

    var sections: [CultProposalsViewModel.Section] {
        
        switch self {
        case let .loaded(sections, _):
            return sections
        default:
            return []
        }
    }
    
    var selectedSectionType: CultProposalsViewModel.Section.`Type` {
        
        switch self {
        case let .loaded(_, type):
            return type
        default:
            return .pending
        }
    }
}
