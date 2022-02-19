// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol WalletsWireframeFactory {

    func makeWireframe(
        _ parent: UIViewController?,
        window: UIWindow?
    ) -> WalletsWireframe
}

// MARK: - DefaultWalletsWireframeFactory

class DefaultWalletsWireframeFactory {

    private let walletsService: WalletsService

    init(_ walletsService: WalletsService) {
        self.walletsService = walletsService
    }
}

// MARK: - WalletsWireframeFactory

extension DefaultWalletsWireframeFactory: WalletsWireframeFactory {

    func makeWireframe(
        _ parent: UIViewController?,
        window: UIWindow?
    ) -> WalletsWireframe {
        DefaultWalletsWireframe(
            parent: parent,
            window: window,
            interactor: DefaultWalletsInteractor(walletsService)
        )
    }
}
