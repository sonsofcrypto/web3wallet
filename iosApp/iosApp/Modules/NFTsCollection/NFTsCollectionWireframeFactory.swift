// Created by web3d4v on 29/05/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol NFTsCollectionWireframeFactory {

    func makeWireframe(
        _ parent: UIViewController?,
        context: NFTsCollectionWireframeContext
    ) -> NFTsCollectionWireframe
}

final class DefaultNFTsCollectionWireframeFactory {

    private let nftDetailWireframeFactory: NFTDetailWireframeFactory
    private let nftsService: NFTsService

    private weak var window: UIWindow?

    init(
        nftDetailWireframeFactory: NFTDetailWireframeFactory,
        nftsService: NFTsService
    ) {
        self.nftDetailWireframeFactory = nftDetailWireframeFactory
        self.nftsService = nftsService
    }
}

extension DefaultNFTsCollectionWireframeFactory: NFTsCollectionWireframeFactory {

    func makeWireframe(
        _ parent: UIViewController?,
        context: NFTsCollectionWireframeContext
    ) -> NFTsCollectionWireframe {
        
        DefaultNFTsCollectionWireframe(
            parent: parent!,
            context: context,
            nftDetailWireframeFactory: nftDetailWireframeFactory,
            nftsService: nftsService
        )
    }
}
