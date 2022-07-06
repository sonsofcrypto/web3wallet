// Created by web3d4v on 06/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

struct TokenSendViewModel {
    
    let title: String
    let content: Content
    
    enum Content {
        case loading
        case loaded(Item)
        case error(error: AppsViewModel.Error)
    }
}

extension TokenSendViewModel {
    
    struct Item {
        
        let name: String
        let symbol: String
        let address: String
        let disclaimer: String
    }
}

extension TokenSendViewModel {

    struct Error {
        
        let title: String
        let body: String
        let actions: [String]
    }
}

extension TokenSendViewModel {

    var data: TokenSendViewModel.Item? {
        switch content {
        case let .loaded(item):
            return item
        default:
            return nil
        }
    }
}
