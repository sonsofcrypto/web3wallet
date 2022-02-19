// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol NFTsWireframeFactory {

    func makeWireframe(_ parent: UIViewController) -> NFTsWireframe
}

// MARK: - DefaultNFTsWireframeFactory

class DefaultNFTsWireframeFactory {

    private let service: NFTsService

    private weak var window: UIWindow?

    init(
        _ service: NFTsService
    ) {
        self.service = service
    }
}

// MARK: - NFTsWireframeFactory

extension DefaultNFTsWireframeFactory: NFTsWireframeFactory {

    func makeWireframe(_ parent: UIViewController) -> NFTsWireframe {
        DefaultNFTsWireframe(
            parent: UIViewController,
            interactor: service
        )
    }
}