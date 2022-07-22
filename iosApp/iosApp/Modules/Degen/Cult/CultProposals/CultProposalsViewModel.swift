// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

enum CultProposalsViewModel {
    case loading
    case loaded(sections: [Section])
    case error(error: AppsViewModel.Error)
}

extension CultProposalsViewModel {
    
    struct Section {
        
        let title: String
        let horizontalScrolling: Bool
        let items: [Item]
    }

    struct Item {
        
        let id: String
        let title: String
        let approved: Vote
        let rejected: Vote
        let approveButtonTitle: String
        let rejectButtonTitle: String
        let isNew: Bool
        let date: Date
        
        struct Vote {
            
            let name: String
            let value: Float
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

    var sections: [CultProposalsViewModel.Section] {
        
        switch self {
        case let .loaded(sections):
            return sections
        default:
            return []
        }
    }
}
