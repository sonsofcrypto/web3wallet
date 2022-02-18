// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol NetworksWireframeFactory {

    func makeWireframe(_ parent: UIViewController) -> NetworksWireframe
}

// MARK: - DefaultNetworksWireframeFactory

class DefaultNetworksWireframeFactory {

    private let networksService: NetworksService

    init(_ networksService: NetworksService) {
        self.networksService = networksService
    }
}

// MARK: - NetworksWireframeFactory

extension DefaultNetworksWireframeFactory: NetworksWireframeFactory {

    func makeWireframe(_ parent: UIViewController) -> NetworksWireframe {
        DefaultNetworksWireframe(
            parent: parent,
            interactor: DefaultNetworksInteractor(networksService)
        )
    }
}