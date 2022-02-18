// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol SwapWireframeFactory {

    func makeWireframe() -> SwapWireframe
}

// MARK: - DefaultSwapWireframeFactory

class DefaultSwapWireframeFactory {

    private let service: DegenService

    private weak var window: UIWindow?

    init(
        window: UIWindow?,
        service: DegenService
    ) {
        self.window = window
        self.service = service
    }
}

// MARK: - SwapWireframeFactory

extension DefaultSwapWireframeFactory: SwapWireframeFactory {

    func makeWireframe() -> SwapWireframe {
        DefaultSwapWireframe(
            interactor: DefaultSwapInteractor(),
            window: window
        )
    }
}