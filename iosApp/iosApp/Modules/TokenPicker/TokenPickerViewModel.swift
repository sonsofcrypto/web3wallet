// Created by web3d4v on 06/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

struct TokenPickerViewModel {

    let title: String
    let allowMultiSelection: Bool
    let showAddCustomToken: Bool
    let content: Content
}

extension TokenPickerViewModel {
    
    enum Content {
        case loading
        case loaded(sections: [Section])
        case error(error: AppsViewModel.Error)
    }

    enum Section {

        //case networks(items: [Network])
        case tokens(name: String, items: [Token])
        
        var name: String {
            
            switch self {
            case let .tokens(name, _):
                return name
            }
        }
    }
    
    struct Network {
        
        let iconName: String
        let name: String
    }
    
    struct Token {
        
        let image: UIImage
        let symbol: String
        let name: String
        let network: String?
        let type: TokenType
        let position: Position
        let tokenId: String
        
        enum Position {
            
            case onlyOne
            case first
            case middle
            case last
        }
    }
    
    struct TokenType {
        
        let isSelected: Bool?
        let balance: Balance?
        
        struct Balance {
            
            let tokens: String
            let usdTotal: String
        }
    }
}

extension TokenPickerViewModel {

    struct Error {
        
        let title: String
        let body: String
        let actions: [String]
    }
}

extension TokenPickerViewModel {

    func sections() -> [TokenPickerViewModel.Section] {
        switch content {
        case let .loaded(sections):
            return sections
        default:
            return []
        }
    }

}
