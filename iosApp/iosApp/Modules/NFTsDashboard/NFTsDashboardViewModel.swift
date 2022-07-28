// Created by web3d4v on 24/05/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

enum NFTsDashboardViewModel {
    
    case loading
    case error(EmbeddedErrorCollectionViewCell.ViewModel)
    case loaded(nfts: [NFT], collections: [Collection])
}

extension NFTsDashboardViewModel {
    
    struct NFT {
        
        let identifier: String
        let image: String
    }
    
    struct Collection {
        
        let identifier: String
        let coverImage: String
        let title: String
        let author: String
    }
}

extension NFTsDashboardViewModel {
    
    var nfts: [NFT] {
        
        switch self {
        case .loading, .error:
            return []
        case let .loaded(nfts, _):
            return nfts
        }
    }

    var collections: [Collection] {
        
        switch self {
        case .loading, .error:
            return []
        case let .loaded(_, collections):
            return collections
        }
    }
}
