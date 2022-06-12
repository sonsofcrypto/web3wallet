// Created by web3d4v on 24/05/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

struct NFTsDashboardViewModel {
    
    let nfts: [NFT]
    let collections: [Collection]
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
