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
    private let ammsWireframeFactory: AMMsWireframeFactory

    private weak var window: UIWindow?

    init(
        _ service: DegenService,
        ammsWireframeFactory: AMMsWireframeFactory
    ) {
        self.service = service
        self.ammsWireframeFactory = ammsWireframeFactory
    }
}

// MARK: - DegenWireframeFactory

extension DefaultDegenWireframeFactory: DegenWireframeFactory {

    func makeWireframe(_ parent: UIViewController) -> DegenWireframe {
        DefaultDegenWireframe(
            parent: parent,
            interactor: DefaultDegenInteractor(service),
            ammsWireframeFactory: ammsWireframeFactory
        )
    }
}