// Created by web3d4v on 06/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

struct TokenPickerViewModel {

    let title: String
    let allowMultiSelection: Bool
    let content: Content
}

extension TokenPickerViewModel {
    
    enum Content {
        case loading
        case loaded(filters: [Filter], sections: [Section])
        case error(error: AppsViewModel.Error)
    }

    struct Filter {
        
        let type: `Type`
        let isSelected: Bool
    
        enum `Type` {
            
            case all(name: String)
            case item(icon: Data, name: String)
        }
    }

    struct Section {
        
        let name: String
        let items: [Token]
    }
    
    struct Token {
        
        let image: UIImage
        let symbol: String
        let name: String
        let network: String?
        let type: TokenType
        let position: Position
        
        enum Position {
            
            case onlyOne
            case first
            case middle
            case last
        }
    }
    
    enum TokenType {
        
        case receive
        case send(tokens: String, usdTotal: String)
        case multiSelect(isSelected: Bool)
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

    func filters() -> [TokenPickerViewModel.Filter] {
        switch content {
        case let .loaded(filters, _):
            return filters
        default:
            return []
        }
    }
    
    func sections() -> [TokenPickerViewModel.Section] {
        switch content {
        case let .loaded(_, sections):
            return sections
        default:
            return []
        }
    }

}
