// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol DegenWireframeFactory {

    func makeWireframe(_ parent: UIViewController) -> DegenWireframe
}

// MARK: - DefaultDegenWireframeFactory

class DefaultDegenWireframeFactory {

    private let service: DegenService

    private weak var window: UIWindow?

    init(
        _ service: DegenService
    ) {
        self.service = service
    }
}

// MARK: - DegenWireframeFactory

extension DefaultDegenWireframeFactory: DegenWireframeFactory {

    func makeWireframe(_ parent: UIViewController) -> DegenWireframe {
        DefaultDegenWireframe(
            parent: parent,
            interactor: DefaultDegenInteractor(service)
        )
    }
}