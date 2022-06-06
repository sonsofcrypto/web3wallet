// Created by web3d4v on 02/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

enum ChatViewModel {
    case loading
    case loaded(items: [Item], selectedIdx: Int)
    case error(error: AppsViewModel.Error)
}

extension ChatViewModel {

    struct Item {
        let owner: Owner
        let message: String
        
        enum Owner {
            case me
            case other
        }
    }
}

extension ChatViewModel {

    struct Error {
        
        let title: String
        let body: String
        let actions: [String]
    }
}

extension ChatViewModel {

    func items() -> [ChatViewModel.Item] {
        switch self {
        case let .loaded(items, _):
            return items
        default:
            return []
        }
    }

    func selectedIdx() -> Int? {
        switch self {
        case let .loaded(_, idx):
            return idx
        default:
            return nil
        }
    }
}
