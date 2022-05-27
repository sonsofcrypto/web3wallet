// Created by web3d4v on 24/05/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol NFTsDashboardWireframeFactory {

    func makeWireframe(_ parent: TabBarController) -> NFTsDashboardWireframe
}

final class DefaultNFTsDashboardWireframeFactory {

    private let nftsService: NFTsService

    private weak var window: UIWindow?

    init(
        nftsService: NFTsService
    ) {
        self.nftsService = nftsService
    }
}

extension DefaultNFTsDashboardWireframeFactory: NFTsDashboardWireframeFactory {

    func makeWireframe(_ parent: TabBarController) -> NFTsDashboardWireframe {
        
        DefaultNFTsDashboardWireframe(
            parent: parent,
            nftsService: nftsService
        )
    }
}
