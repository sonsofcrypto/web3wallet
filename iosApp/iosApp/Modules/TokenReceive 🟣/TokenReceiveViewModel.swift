// Created by web3d4v on 13/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

struct TokenReceiveViewModel {
    let title: String
    let content: Content
}

extension TokenReceiveViewModel {
    
    enum Content {
        case loading
        case loaded(Item)
        case error(error: AppsViewModel.Error)
    }
}

extension TokenReceiveViewModel {
    
    struct Item {
        let name: String
        let symbol: String
        let address: String
        let disclaimer: String
    }
}

extension TokenReceiveViewModel {

    struct Error {
        let title: String
        let body: String
        let actions: [String]
    }
}

extension TokenReceiveViewModel {
    var data: TokenReceiveViewModel.Item? {
        switch content {
        case let .loaded(item):
            return item
        default:
            return nil
        }
    }
}
