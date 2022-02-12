// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol WalletsWireframeFactory {

    func makeWireframe() -> WalletsWireframe
}

// MARK: - DefaultWalletsWireframeFactory

class DefaultWalletsWireframeFactory {

    private let walletsService: WalletsService

    private weak var window: UIWindow?

    init(
        window: UIWindow?,
        walletsService: WalletsService
    ) {
        self.window = window
        self.walletsService = walletsService
    }
}

// MARK: - WalletsWireframeFactory

extension DefaultWalletsWireframeFactory: WalletsWireframeFactory {

    func makeWireframe() -> WalletsWireframe {
        DefaultWalletsWireframe(
            interactor: DefaultWalletsInteractor(walletsService),
            window: window
        )
    }
}