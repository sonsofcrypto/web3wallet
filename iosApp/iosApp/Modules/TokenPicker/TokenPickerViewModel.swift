// Created by web3d4v on 06/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

struct TokenPickerViewModel {
    
    let title: String
    let content: Content
}

extension TokenPickerViewModel {
    
    enum Content {
        case loading
        case loaded(filters: [Filter], items: [Item])
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

    enum Item {
        
        case group(Group)
        case token(Token)
    }
    
    struct Group {
        let name: String
    }
    
    struct Token {
        let image: UIImage
        let symbol: String
        let name: String
        let network: String
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
    
    func items() -> [TokenPickerViewModel.Item] {
        switch content {
        case let .loaded(_, items):
            return items
        default:
            return []
        }
    }
}
