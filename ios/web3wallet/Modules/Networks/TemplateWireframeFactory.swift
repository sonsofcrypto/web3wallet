// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol NetworksWireframeFactory {

    func makeWireframe() -> NetworksWireframe
}

// MARK: - DefaultNetworksWireframeFactory

class DefaultNetworksWireframeFactory {

    private let networksService: NetworksSerivce

    private weak var window: UIWindow?

    init(
        window: UIWindow?,
        networksService: NetworksSerivce
    ) {
        self.window = window
        self.service = service
    }
}

// MARK: - NetworksWireframeFactory

extension DefaultNetworksWireframeFactory: NetworksWireframeFactory {

    func makeWireframe() -> NetworksWireframe {
        DefaultNetworksWireframe(
            interactor: DefaultNetworksInteractor(service),
            window: window
        )
    }
}