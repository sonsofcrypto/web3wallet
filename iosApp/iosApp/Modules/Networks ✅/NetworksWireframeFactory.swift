// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

protocol NetworksWireframeFactory {
    func makeWireframe(_ parent: UIViewController) -> NetworksWireframe
}

final class DefaultNetworksWireframeFactory {
    private let alertWireframeFactory: AlertWireframeFactory
    private let networkSettingsWireframeFactory: NetworkSettingsWireframeFactory
    private let networksService: NetworksService

    init(
        alertWireframeFactory: AlertWireframeFactory,
        networkSettingsWireframeFactory: NetworkSettingsWireframeFactory,
        networksService: NetworksService
    ) {
        self.alertWireframeFactory = alertWireframeFactory
        self.networkSettingsWireframeFactory = networkSettingsWireframeFactory
        self.networksService = networksService
    }
}

extension DefaultNetworksWireframeFactory: NetworksWireframeFactory {

    func makeWireframe(_ parent: UIViewController) -> NetworksWireframe {
        DefaultNetworksWireframe(
            parent: parent,
            networksService: networksService,
            alertWireframeFactory: alertWireframeFactory,
            networkSettingsWireframeFactory: networkSettingsWireframeFactory
        )
    }
}

// MARK: - NetworksWireframeFactoryAssembler

final class NetworksWireframeFactoryAssembler: AssemblerComponent {

    func register(to registry: AssemblerRegistry) {
        registry.register(scope: .instance) { resolver -> NetworksWireframeFactory in
            DefaultNetworksWireframeFactory(
                alertWireframeFactory: resolver.resolve(),
                networkSettingsWireframeFactory: resolver.resolve(),
                networksService: resolver.resolve()
            )
        }
    }
}
