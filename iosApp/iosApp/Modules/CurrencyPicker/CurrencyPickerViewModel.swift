// Created by web3d4v on 06/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3walletcore

struct CurrencyPickerViewModel {
    let title: String
    let allowMultiSelection: Bool
    let showAddCustomCurrency: Bool
    let content: Content
}

extension CurrencyPickerViewModel {
    
    enum Content {
        case loading
        case loaded(sections: [Section])
        case error(error: AppsViewModel.Error)
    }

    struct Section {
        let name: String
        let type: `Type`
        let items: [Item]
        
        enum `Type` {
            case networks
            case tokens
        }
    }
    
    enum Item {
        case network(Network)
        case currency(Currency)
    }
    
    struct Network {
        let networkId: String
        let iconName: String
        let name: String
        let isSelected: Bool
    }
    
    struct Currency {
        let id: String
        let imageName: String
        let symbol: String
        let name: String
        let type: CurrencyType
        let position: Position
        
        enum Position {
            case onlyOne
            case first
            case middle
            case last
        }
    }
    
    struct CurrencyType {
        let isSelected: Bool?
        let balance: Balance?
        
        struct Balance {
            let tokens: [Formatters.Output]
            let usdTotal: [Formatters.Output]
        }
    }
}

extension CurrencyPickerViewModel {

    struct Error {
        let title: String
        let body: String
        let actions: [String]
    }
}

extension CurrencyPickerViewModel {

    var sections: [CurrencyPickerViewModel.Section] {
        switch content {
        case let .loaded(sections):
            return sections
        default:
            return []
        }
    }
}
