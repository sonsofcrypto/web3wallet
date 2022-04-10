// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol KeyStoreWireframeFactory {

    func makeWireframe(
        _ parent: UIViewController?,
        window: UIWindow?
    ) -> KeyStoreWireframe
}

// MARK: - DefaultKeyStoreWireframeFactory

class DefaultKeyStoreWireframeFactory {

    private let walletsService: KeyStoreService

    init(_ walletsService: KeyStoreService) {
        self.walletsService = walletsService
    }
}

// MARK: - WalletsWireframeFactory

extension DefaultKeyStoreWireframeFactory: KeyStoreWireframeFactory {

    func makeWireframe(
        _ parent: UIViewController?,
        window: UIWindow?
    ) -> KeyStoreWireframe {
        DefaultKeyStoreWireframe(
            parent: parent,
            window: window,
            interactor: DefaultKeyStoreInteractor(walletsService)
        )
    }
}
