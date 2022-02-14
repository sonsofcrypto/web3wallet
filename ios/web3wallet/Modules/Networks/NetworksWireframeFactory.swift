// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol NetworksWireframeFactory {

    func makeWireframe() -> NetworksWireframe
}

// MARK: - DefaultNetworksWireframeFactory

class DefaultNetworksWireframeFactory {

    private let networksService: NetworksService

    private weak var window: UIWindow?

    init(
        window: UIWindow?,
        networksService: NetworksService
    ) {
        self.window = window
        self.networksService = networksService
    }
}

// MARK: - NetworksWireframeFactory

extension DefaultNetworksWireframeFactory: NetworksWireframeFactory {

    func makeWireframe() -> NetworksWireframe {
        DefaultNetworksWireframe(
            interactor: DefaultNetworksInteractor(networksService),
            window: window
        )
    }
}