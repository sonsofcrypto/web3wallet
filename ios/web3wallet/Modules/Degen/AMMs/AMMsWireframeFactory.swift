// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol AMMsWireframeFactory {

    func makeWireframe() -> AMMsWireframe
}

// MARK: - DefaultAMMsWireframeFactory

class DefaultAMMsWireframeFactory {

    private let degenService: DegenService

    private weak var window: UIWindow?

    init(
        window: UIWindow?,
        degenService: DegenService
    ) {
        self.window = window
        self.degenService = degenService
    }
}

// MARK: - AMMsWireframeFactory

extension DefaultAMMsWireframeFactory: AMMsWireframeFactory {

    func makeWireframe() -> AMMsWireframe {
        DefaultAMMsWireframe(
            interactor: DefaultAMMsInteractor(degenService),
            window: window
        )
    }
}