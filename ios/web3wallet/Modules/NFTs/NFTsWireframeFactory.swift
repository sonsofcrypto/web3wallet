// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol NFTsWireframeFactory {

    func makeWireframe() -> NFTsWireframe
}

// MARK: - DefaultNFTsWireframeFactory

class DefaultNFTsWireframeFactory {

    private let service: NFTsService

    private weak var window: UIWindow?

    init(
        window: UIWindow?,
        service: NFTsService
    ) {
        self.window = window
        self.service = service
    }
}

// MARK: - NFTsWireframeFactory

extension DefaultNFTsWireframeFactory: NFTsWireframeFactory {

    func makeWireframe() -> NFTsWireframe {
        DefaultNFTsWireframe(
            interactor: DefaultNFTsInteractor(service),
            window: window
        )
    }
}