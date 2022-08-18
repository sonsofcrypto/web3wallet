// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3lib

protocol NetworksWireframeFactory {
    func makeWireframe(_ parent: UIViewController) -> NetworksWireframe
}

final class DefaultNetworksWireframeFactory {
    private let alertWireframeFactory: AlertWireframeFactory
    private let networksService: NetworksService

    init(
        alertWireframeFactory: AlertWireframeFactory,
        networksService: NetworksService
    ) {
        self.alertWireframeFactory = alertWireframeFactory
        self.networksService = networksService
    }
}

extension DefaultNetworksWireframeFactory: NetworksWireframeFactory {

    func makeWireframe(_ parent: UIViewController) -> NetworksWireframe {
        DefaultNetworksWireframe(
            parent: parent,
            networksService: networksService,
            alertWireframeFactory: alertWireframeFactory
        )
    }
}

// MARK: - NetworksWireframeFactoryAssembler

final class NetworksWireframeFactoryAssembler: AssemblerComponent {

    func register(to registry: AssemblerRegistry) {
        registry.register(scope: .instance) { resolver -> NetworksWireframeFactory in
            DefaultNetworksWireframeFactory(
                alertWireframeFactory: resolver.resolve(),
                networksService: resolver.resolve()
            )
        }
    }
}