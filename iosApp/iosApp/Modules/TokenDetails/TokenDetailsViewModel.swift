// Created by web3d4v on 13/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

struct TokenDetailsViewModel {
    
    let title: String
    let content: Content
    
    enum Content {
        case loading
        case loaded(Item)
        case error(error: AppsViewModel.Error)
    }
}

extension TokenDetailsViewModel {
    
    struct Item {
        
        let name: String
        let symbol: String
        let address: String
        let disclaimer: String
    }
}

extension TokenDetailsViewModel {

    struct Error {
        
        let title: String
        let body: String
        let actions: [String]
    }
}

extension TokenDetailsViewModel {

    var data: TokenDetailsViewModel.Item? {
        switch content {
        case let .loaded(item):
            return item
        default:
            return nil
        }
    }
}
