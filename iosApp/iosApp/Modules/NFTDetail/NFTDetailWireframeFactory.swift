// Created by web3d4v on 27/05/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3lib

protocol NFTDetailWireframeFactory {

    func makeWireframe(
        _ parent: UIViewController?,
        context: NFTDetailWireframeContext
    ) -> NFTDetailWireframe
}

final class DefaultNFTDetailWireframeFactory {

    private let nftSendWireframeFactory: NFTSendWireframeFactory
    private let nftsService: NFTsService
    private let networksService: NetworksService
    
    private weak var window: UIWindow?

    init(
        nftSendWireframeFactory: NFTSendWireframeFactory,
        nftsService: NFTsService,
        networksService: NetworksService
    ) {
        self.nftSendWireframeFactory = nftSendWireframeFactory
        self.nftsService = nftsService
        self.networksService = networksService
    }
}

extension DefaultNFTDetailWireframeFactory: NFTDetailWireframeFactory {

    func makeWireframe(
        _ parent: UIViewController?,
        context: NFTDetailWireframeContext
    ) -> NFTDetailWireframe {
        
        DefaultNFTDetailWireframe(
            parent: parent!,
            context: context,
            nftSendWireframeFactory: nftSendWireframeFactory,
            nftsService: nftsService,
            networksService: networksService
        )
    }
}
