// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol DegenWireframeFactory {

    func makeWireframe() -> DegenWireframe
}

// MARK: - DefaultDegenWireframeFactory

class DefaultDegenWireframeFactory {

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

// MARK: - DegenWireframeFactory

extension DefaultDegenWireframeFactory: DegenWireframeFactory {

    func makeWireframe() -> DegenWireframe {
        DefaultDegenWireframe(
            interactor: DefaultDegenInteractor(service),
            window: window
        ) as! DegenWireframe
    }
}