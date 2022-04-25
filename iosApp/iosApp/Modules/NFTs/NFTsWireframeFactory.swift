// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol NFTsWireframeFactory {

    func makeWireframe(_ parent: TabBarController) -> NFTsWireframe
}

// MARK: - DefaultNFTsWireframeFactory

final class DefaultNFTsWireframeFactory {

    private let nftsService: NFTsService

    private weak var window: UIWindow?

    init(
        nftsService: NFTsService
    ) {
        self.nftsService = nftsService
    }
}

// MARK: - NFTsWireframeFactory

extension DefaultNFTsWireframeFactory: NFTsWireframeFactory {

    func makeWireframe(_ parent: TabBarController) -> NFTsWireframe {
        DefaultNFTsWireframe(
            parent: parent,
            nftsService: nftsService
        )
    }
}
