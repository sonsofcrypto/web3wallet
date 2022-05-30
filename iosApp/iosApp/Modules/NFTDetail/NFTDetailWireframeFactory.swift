// Created by web3d4v on 27/05/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol NFTDetailWireframeFactory {

    func makeWireframe(
        _ parent: UIViewController,
        context: NFTDetailWireframeContext
    ) -> NFTDetailWireframe
}

final class DefaultNFTDetailWireframeFactory {

    private let nftsService: NFTsService

    private weak var window: UIWindow?

    init(
        nftsService: NFTsService
    ) {
        self.nftsService = nftsService
    }
}

extension DefaultNFTDetailWireframeFactory: NFTDetailWireframeFactory {

    func makeWireframe(
        _ parent: UIViewController,
        context: NFTDetailWireframeContext
    ) -> NFTDetailWireframe {
        
        DefaultNFTDetailWireframe(
            parent: parent,
            context: context,
            nftsService: nftsService
        )
    }
}
