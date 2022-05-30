// Created by web3d4v on 27/05/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

enum NFTDetailViewModel {
    
    case loading
    case loaded(nft: NFTItem, collection: NFTCollection)
    case error(error: NFTDetailViewModel.Error)
}

extension NFTDetailViewModel {
    
    var nftItem: NFTItem? {
        
        switch self {
        case let .loaded(nftItem, _):
            return nftItem
        case .loading, .error:
            return nil
        }
    }
}

extension NFTDetailViewModel {

    struct Error {
        
        let title: String
        let body: String
        let actions: [String]
    }
}
