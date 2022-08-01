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
        case loaded(sections: [Section])
        case error(error: AppsViewModel.Error)
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
        let tokenId: String
        
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

    func sections() -> [TokenPickerViewModel.Section] {
        switch content {
        case let .loaded(sections):
            return sections
        default:
            return []
        }
    }

}
