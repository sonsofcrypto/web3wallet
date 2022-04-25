// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol SwapWireframeFactory {

    func makeWireframe(_ parent: UIViewController, dapp: DApp) -> SwapWireframe
}

final class DefaultSwapWireframeFactory {

    private let degenService: DegenService

    init(
        degenService: DegenService
    ) {
        self.degenService = degenService
    }
}

extension DefaultSwapWireframeFactory: SwapWireframeFactory {

    func makeWireframe(_ parent: UIViewController, dapp: DApp) -> SwapWireframe {

        DefaultSwapWireframe(
            parent: parent,
            dapp: dapp,
            degenService: degenService
        )
    }
}
