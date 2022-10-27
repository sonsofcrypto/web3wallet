// Created by web3d4v on 29/05/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3walletcore

enum NFTsCollectionViewModel {
    case loading
    case loaded(collection: NFTCollection, nfts: [NFTItem])
    case error(error: NFTsCollectionViewModel.Error)
}

extension NFTsCollectionViewModel {
    
    var collection: NFTCollection? {
        switch self {
        case let .loaded(collection, _): return collection
        case .loading, .error: return nil
        }
    }
    
    var nfts: [NFTItem] {
        switch self {
        case let .loaded(_, nfts): return nfts
        case .loading, .error: return []
        }
    }
}

extension NFTsCollectionViewModel {

    struct Error {
        let title: String
        let body: String
        let actions: [String]
    }
}
