// Created by web3d4v on 24/05/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol NFTsDashboardWireframeFactory {

    func makeWireframe(_ parent: TabBarController) -> NFTsDashboardWireframe
}

final class DefaultNFTsDashboardWireframeFactory {

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

extension DefaultNFTsDashboardWireframeFactory: NFTsDashboardWireframeFactory {

    func makeWireframe(_ parent: TabBarController) -> NFTsDashboardWireframe {
        
        DefaultNFTsDashboardWireframe(
            parent: parent,
            nftDetailWireframeFactory: nftDetailWireframeFactory,
            nftsService: nftsService
        )
    }
}
