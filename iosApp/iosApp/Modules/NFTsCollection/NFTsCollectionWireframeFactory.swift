// Created by web3d4v on 29/05/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

// MARK: - NFTsCollectionWireframeFactory

protocol NFTsCollectionWireframeFactory {
    func make(
        _ parent: UIViewController?,
        context: NFTsCollectionWireframeContext
    ) -> NFTsCollectionWireframe
}

// MARK: - DefaultNFTsCollectionWireframeFactory

final class DefaultNFTsCollectionWireframeFactory {
    private let nftDetailWireframeFactory: NFTDetailWireframeFactory
    private let nftsService: NFTsService

    init(
        nftDetailWireframeFactory: NFTDetailWireframeFactory,
        nftsService: NFTsService
    ) {
        self.nftDetailWireframeFactory = nftDetailWireframeFactory
        self.nftsService = nftsService
    }
}

extension DefaultNFTsCollectionWireframeFactory: NFTsCollectionWireframeFactory {

    func make(
        _ parent: UIViewController?,
        context: NFTsCollectionWireframeContext
    ) -> NFTsCollectionWireframe {
        DefaultNFTsCollectionWireframe(
            parent,
            context: context,
            nftDetailWireframeFactory: nftDetailWireframeFactory,
            nftsService: nftsService
        )
    }
}

// MARK: - Assembler

final class NFTsCollectionWireframeFactoryAssembler: AssemblerComponent {
    
    func register(to registry: AssemblerRegistry) {
        registry.register(scope: .instance) { resolver -> NFTsCollectionWireframeFactory in
            DefaultNFTsCollectionWireframeFactory(
                nftDetailWireframeFactory: resolver.resolve(),
                nftsService: resolver.resolve()
            )
        }
    }
}
