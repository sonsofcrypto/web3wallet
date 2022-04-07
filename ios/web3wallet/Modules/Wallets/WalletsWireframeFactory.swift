//
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT
//

import UIKit

protocol WalletsWireframeFactory {

    func makeWireframe(
        _ parent: UIViewController?,
        window: UIWindow?
    ) -> WalletsWireframe
}

final class DefaultWalletsWireframeFactory {

    private let walletsService: WalletsService

    init(
        walletsService: WalletsService
    ) {
        self.walletsService = walletsService
    }
}

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
